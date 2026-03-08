import AVFAudio
import Foundation

protocol BreathingAudioSignalProviding: AnyObject, Sendable {
    var onAmplitude: ((Double) -> Void)? { get set }
    func requestPermission() async -> Bool
    func start() throws
    func stop()
}

enum BreathingAudioError: Error {
    case noInputNodeFormat
}

final class BreathingAudioSignalProvider: BreathingAudioSignalProviding, @unchecked Sendable {
    var onAmplitude: ((Double) -> Void)?

    private let session = AVAudioSession.sharedInstance()
    private var engine: AVAudioEngine?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            session.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func start() throws {
        stop()

        try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true, options: [])

        let engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.channelCount > 0 else {
            throw BreathingAudioError.noInputNodeFormat
        }

        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            guard let amplitude = Self.computeAmplitude(buffer: buffer) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onAmplitude?(amplitude)
            }
        }

        engine.prepare()
        try engine.start()
        self.engine = engine
    }

    func stop() {
        guard let engine else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        self.engine = nil
        // Keep the shared audio session active so in-app BGM does not get torn down
        // when temporary overlays (e.g., Guide) pause microphone capture.
    }

    private static func computeAmplitude(buffer: AVAudioPCMBuffer) -> Double? {
        guard
            let channelData = buffer.floatChannelData,
            buffer.frameLength > 0
        else {
            return nil
        }

        let frameCount = Int(buffer.frameLength)
        let firstChannel = channelData[0]

        var sumSquares: Float = 0
        for index in 0..<frameCount {
            let sample = firstChannel[index]
            sumSquares += sample * sample
        }

        let rms = sqrt(sumSquares / Float(frameCount))
        let clamped = max(rms, 0.000_001)
        let decibels = 20 * log10(clamped)
        let amplitude = pow(10.0, Double(decibels) / 20.0)
        return amplitude
    }
}
