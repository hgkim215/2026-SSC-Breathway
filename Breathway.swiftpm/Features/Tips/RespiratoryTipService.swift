import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

protocol RespiratoryTipProviding: Sendable {
    func generateTip(context: RespiratoryTipContext, variationHint: String?) async throws -> RespiratoryTip
}

enum RespiratoryTipError: Error {
    case modelUnavailable
    case malformedResponse
}

struct FoundationModelRespiratoryTipProvider: RespiratoryTipProviding {
    func generateTip(context: RespiratoryTipContext, variationHint: String?) async throws -> RespiratoryTip {
#if canImport(FoundationModels)
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            throw RespiratoryTipError.modelUnavailable
        }

        let instructions = """
        You are a calm respiratory wellness coach for people with breathing discomfort.
        Respond in English only.
        Keep output brief and practical.
        Never provide diagnosis, medication, or treatment claims.
        Return exactly three lines with these prefixes:
        Headline:
        Tip:
        Safety:
        """

        let session = LanguageModelSession(instructions: instructions)

        var prompt = """
        Context: \(context.promptContext).
        Session structure: check-in, breathing 60 seconds, sit-to-stand 15 reps with stand 3s and sit 3s.
        Generate one supportive tip with fresh wording.
        Constraints:
        - Headline: 3 to 6 words.
        - Tip: one sentence, 12 to 18 words.
        - Safety: one sentence, 8 to 14 words.
        """

        if let variationHint, !variationHint.isEmpty {
            prompt += "\nVariation hint: \(variationHint)"
        }

        let response = try await session.respond(to: prompt)
        guard let parsed = parseThreeLineResponse(response.content) else {
            throw RespiratoryTipError.malformedResponse
        }

        return RespiratoryTip(
            headline: parsed.headline,
            body: parsed.tip,
            safetyNote: parsed.safety,
            generatedAt: Date(),
            source: .foundationModel
        )
#else
        throw RespiratoryTipError.modelUnavailable
#endif
    }

    private func parseThreeLineResponse(_ content: String) -> (headline: String, tip: String, safety: String)? {
        let lines = content
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        func extract(_ prefix: String) -> String? {
            guard let line = lines.first(where: { $0.lowercased().hasPrefix(prefix.lowercased()) }) else {
                return nil
            }
            let value = line.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
            return value.isEmpty ? nil : value
        }

        guard
            let headline = extract("Headline:"),
            let tip = extract("Tip:"),
            let safety = extract("Safety:")
        else {
            return nil
        }

        return (headline, tip, safety)
    }
}

struct FallbackRespiratoryTipProvider: RespiratoryTipProviding {
    func generateTip(context: RespiratoryTipContext, variationHint: String?) async throws -> RespiratoryTip {
        let pool = context.fallbackPool
        guard !pool.isEmpty else {
            return RespiratoryTip(
                headline: "Keep your pace steady",
                body: "Focus on calm breathing and gentle movement during your next short session.",
                safetyNote: "Stop and rest if symptoms feel worse than usual.",
                generatedAt: Date(),
                source: .fallback
            )
        }

        let seed = variationHint?.hashValue ?? Int(Date().timeIntervalSince1970)
        let index = abs(seed) % pool.count
        let tip = pool[index]

        return RespiratoryTip(
            headline: tip.headline,
            body: tip.body,
            safetyNote: tip.safetyNote,
            generatedAt: Date(),
            source: .fallback
        )
    }
}

@MainActor
final class RespiratoryTipService {
    private enum Storage {
        static let recentSignaturesKey = "breathway.tip.recentSignatures"
        static let maxSignatures = 8
    }

    private let foundationProvider: any RespiratoryTipProviding
    private let fallbackProvider: any RespiratoryTipProviding
    private let userDefaults: UserDefaults

    init(
        foundationProvider: any RespiratoryTipProviding = FoundationModelRespiratoryTipProvider(),
        fallbackProvider: any RespiratoryTipProviding = FallbackRespiratoryTipProvider(),
        userDefaults: UserDefaults = .standard
    ) {
        self.foundationProvider = foundationProvider
        self.fallbackProvider = fallbackProvider
        self.userDefaults = userDefaults
    }

    func generateTip(context: RespiratoryTipContext) async -> RespiratoryTip {
        if let tip = await attemptFoundationTip(context: context) {
            rememberSignature(of: tip)
            return tip
        }

        let fallback = (try? await fallbackProvider.generateTip(context: context, variationHint: fallbackVariationHint()))
            ?? RespiratoryTip(
                headline: "Stay gentle with movement",
                body: "Use shorter, calmer movement ranges while keeping your breathing rhythm smooth.",
                safetyNote: "Pause immediately if dizziness or chest discomfort appears.",
                generatedAt: Date(),
                source: .fallback
            )

        rememberSignature(of: fallback)
        return fallback
    }

    private func attemptFoundationTip(context: RespiratoryTipContext) async -> RespiratoryTip? {
        let attempts = [foundationVariationHint(), foundationVariationHint()]

        for hint in attempts {
            guard let tip = try? await foundationProvider.generateTip(context: context, variationHint: hint) else {
                continue
            }

            if !isDuplicate(tip) {
                return tip
            }
        }

        return nil
    }

    private func signature(for tip: RespiratoryTip) -> String {
        let combined = "\(tip.headline)|\(tip.body)|\(tip.safetyNote)"
        return combined
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func recentSignatures() -> [String] {
        userDefaults.stringArray(forKey: Storage.recentSignaturesKey) ?? []
    }

    private func rememberSignature(of tip: RespiratoryTip) {
        var signatures = recentSignatures()
        let sig = signature(for: tip)

        signatures.removeAll(where: { $0 == sig })
        signatures.append(sig)

        if signatures.count > Storage.maxSignatures {
            signatures.removeFirst(signatures.count - Storage.maxSignatures)
        }

        userDefaults.set(signatures, forKey: Storage.recentSignaturesKey)
    }

    private func isDuplicate(_ tip: RespiratoryTip) -> Bool {
        recentSignatures().contains(signature(for: tip))
    }

    private func foundationVariationHint() -> String {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        return "timestamp: \(timestamp), style seed: \(Int.random(in: 1000...9999))"
    }

    private func fallbackVariationHint() -> String {
        String(Int.random(in: 1000...9999))
    }
}
