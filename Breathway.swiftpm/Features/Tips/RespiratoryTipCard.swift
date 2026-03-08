import SwiftUI

struct RespiratoryTipCard: View {
    enum Tone {
        case onGlass
        case onImage
    }

    let title: String
    let state: RespiratoryTipState
    var compact: Bool = false
    var tone: Tone = .onImage

    private var titleFont: Font {
        .system(size: compact ? 14 : 16, weight: .bold)
    }

    private var headlineFont: Font {
        .system(size: compact ? 18 : 20, weight: .semibold)
    }

    private var bodyFont: Font {
        .system(size: compact ? 14 : 16, weight: .medium)
    }

    private var safetyFont: Font {
        .system(size: compact ? 12 : 13, weight: .medium)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 8) {
            header

            switch state {
            case .idle, .loading:
                loadingBody
            case .loaded(let tip):
                loadedBody(tip)
            }
        }
        .padding(compact ? 12 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(titleFont)
                .foregroundStyle(titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 0)

            if case .loaded(let tip) = state {
                Text(tip.source.rawValue)
                    .font(.system(size: compact ? 11 : 12, weight: .semibold))
                    .foregroundStyle(BW2Tokens.ColorPalette.textOnImagePrimary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(sourceBadgeBackground)
                    .clipShape(Capsule(style: .continuous))
            }
        }
    }

    private var loadingBody: some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 6) {
            Text("Generating a fresh tip for today...")
                .font(headlineFont)
                .foregroundStyle(headlineColor)

            Text("Using on-device intelligence when available.")
                .font(bodyFont)
                .foregroundStyle(bodyColor)

            Text("Safety: stop and rest if symptoms worsen.")
                .font(safetyFont)
                .foregroundStyle(safetyColor)
        }
        .redacted(reason: .placeholder)
    }

    private func loadedBody(_ tip: RespiratoryTip) -> some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 6) {
            Text(tip.headline)
                .font(headlineFont)
                .foregroundStyle(headlineColor)
                .lineLimit(compact ? 2 : 3)
                .minimumScaleFactor(0.82)

            Text(tip.body)
                .font(bodyFont)
                .foregroundStyle(bodyColor)
                .lineLimit(compact ? 3 : 4)
                .minimumScaleFactor(0.82)

            Text("Safety: \(tip.safetyNote)")
                .font(safetyFont)
                .foregroundStyle(safetyColor)
                .lineLimit(compact ? 3 : 4)
                .minimumScaleFactor(0.82)
        }
    }

    private var backgroundColor: Color {
        switch tone {
        case .onGlass: BW2Tokens.ColorPalette.surfaceGlassHigh.opacity(0.55)
        case .onImage: BW2Tokens.ColorPalette.surfaceOnImageSoft
        }
    }

    private var borderColor: Color {
        switch tone {
        case .onGlass: BW2Tokens.ColorPalette.borderGlass
        case .onImage: BW2Tokens.ColorPalette.borderOnImage
        }
    }

    private var sourceBadgeBackground: Color {
        switch tone {
        case .onGlass: BW2Tokens.ColorPalette.deep700.opacity(0.88)
        case .onImage: BW2Tokens.ColorPalette.surfaceOnImageStrong
        }
    }

    private var titleColor: Color {
        switch tone {
        case .onGlass: BW2Tokens.ColorPalette.textSecondary
        case .onImage: BW2Tokens.ColorPalette.textOnImageSecondary
        }
    }

    private var headlineColor: Color {
        switch tone {
        case .onGlass: BW2Tokens.ColorPalette.textPrimary
        case .onImage: BW2Tokens.ColorPalette.textOnImagePrimary
        }
    }

    private var bodyColor: Color {
        switch tone {
        case .onGlass: BW2Tokens.ColorPalette.textSecondary
        case .onImage: BW2Tokens.ColorPalette.textOnImageSecondary
        }
    }

    private var safetyColor: Color {
        switch tone {
        case .onGlass: BW2Tokens.ColorPalette.deep700.opacity(0.8)
        case .onImage: BW2Tokens.ColorPalette.textOnImageMuted
        }
    }
}
