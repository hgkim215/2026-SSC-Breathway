import SwiftUI

struct BWLiquidGlass: ViewModifier {
    let cornerRadius: CGFloat
    let strokeColor: Color
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowY: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .background(.ultraThinMaterial, in: shape)
            .overlay(
                shape.fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.30),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.04),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .allowsHitTesting(false)
            )
            .overlay(
                shape.stroke(strokeColor, lineWidth: 1)
                    .allowsHitTesting(false)
            )
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
    }
}

struct BWAdaptiveGlass: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color?
    let interactive: Bool
    let strokeColor: Color
    let shadowColor: Color
    let shadowRadius: CGFloat
    let shadowY: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .bwLiquidGlass(
                cornerRadius: cornerRadius,
                strokeColor: strokeColor,
                shadowColor: shadowColor,
                shadowRadius: shadowRadius,
                shadowY: shadowY
            )
            .overlay(
                Group {
                    if let tint {
                        shape
                            .fill(tint.opacity(interactive ? 0.24 : 0.18))
                            .allowsHitTesting(false)
                    }
                }
            )
    }
}

extension View {
    func bwLiquidGlass(
        cornerRadius: CGFloat,
        strokeColor: Color = BW2Tokens.ColorPalette.borderGlass,
        shadowColor: Color = Color.black.opacity(0.14),
        shadowRadius: CGFloat = 16,
        shadowY: CGFloat = 10
    ) -> some View {
        modifier(
            BWLiquidGlass(
                cornerRadius: cornerRadius,
                strokeColor: strokeColor,
                shadowColor: shadowColor,
                shadowRadius: shadowRadius,
                shadowY: shadowY
            )
        )
    }

    func bwAdaptiveGlass(
        cornerRadius: CGFloat,
        tint: Color? = nil,
        interactive: Bool = false,
        strokeColor: Color = BW2Tokens.ColorPalette.borderGlass,
        shadowColor: Color = Color.black.opacity(0.14),
        shadowRadius: CGFloat = 16,
        shadowY: CGFloat = 10
    ) -> some View {
        modifier(
            BWAdaptiveGlass(
                cornerRadius: cornerRadius,
                tint: tint,
                interactive: interactive,
                strokeColor: strokeColor,
                shadowColor: shadowColor,
                shadowRadius: shadowRadius,
                shadowY: shadowY
            )
        )
    }
}
