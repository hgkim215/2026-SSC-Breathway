import SwiftUI

enum BW2Tokens {
    enum ColorPalette {
        static let fog100 = Color(hex: "D6E1EA")
        static let fog200 = Color(hex: "AFC3D4")
        static let fog300 = Color(hex: "93AFC6")
        static let fog500 = Color(hex: "5F7F97")
        static let deep700 = Color(hex: "344E64")
        static let deep800 = Color(hex: "233A4D")
        static let deep900 = Color(hex: "142A3D")
        static let teal400 = Color(hex: "25C8C2")
        static let teal500 = Color(hex: "1FB7B0")
        static let gold400 = Color(hex: "E0B84E")
        static let gold500 = Color(hex: "D6A93D")
        static let safety500 = Color(hex: "D94B57")

        // light/high contrast tokens aligned with Breathway.pen v2 spec
        static let textPrimary = Color(hex: "0A1622")
        static let textSecondary = Color(hex: "233A4D")
        static let textInverse = Color(hex: "F4F9FD")
        static let textOnGlass = Color(hex: "142A3D")

        static let borderGlass = Color.white.opacity(0.56)
        static let surfaceGlassHigh = Color(hex: "FFFFFF", alpha: 0.94)
        static let chipFill = Color(hex: "4F677B", alpha: 0.80)

        // on-image accessibility palette
        static let textOnImagePrimary = Color(hex: "F7FAFE")
        static let textOnImageSecondary = Color(hex: "DCE8F4")
        static let textOnImageMuted = Color(hex: "C5D6E7")

        static let surfaceOnImageStrong = Color(hex: "10233B", alpha: 0.80)
        static let surfaceOnImageMedium = Color(hex: "10233B", alpha: 0.60)
        static let surfaceOnImageSoft = Color(hex: "10233B", alpha: 0.45)
        static let borderOnImage = Color(hex: "FFFFFF", alpha: 0.40)

        static let overlayCoolTop = Color(hex: "081627", alpha: 0.40)
        static let overlayCoolBottom = Color(hex: "040A14", alpha: 0.66)
        static let overlayWarmTop = Color(hex: "2A1712", alpha: 0.35)
        static let overlayWarmBottom = Color(hex: "140D11", alpha: 0.64)
    }

    enum Space {
        static let x4: CGFloat = 4
        static let x8: CGFloat = 8
        static let x10: CGFloat = 10
        static let x12: CGFloat = 12
        static let x14: CGFloat = 14
        static let x16: CGFloat = 16
        static let x20: CGFloat = 20
        static let x24: CGFloat = 24
        static let x32: CGFloat = 32
    }

    enum Radius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 20
        static let large: CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Size {
        static let buttonMin: CGFloat = 56
        static let safetyMin: CGFloat = 72
        static let contentMax: CGFloat = 1200
        static let homeCanvasWidth: CGFloat = 1194
        static let homeCanvasHeight: CGFloat = 834
        static let globalTopContentInset: CGFloat = 14
    }

    enum Motion {
        static let fast = 0.30
        static let medium = 0.50
        static let slow = 2.0
    }

    enum Typography {
        static let brand = Font.system(size: 34, weight: .bold, design: .default)
        static let missionLabel = Font.system(size: 14, weight: .semibold, design: .default)
        static let missionTitle = Font.system(size: 42, weight: .bold, design: .default)
        static let title24 = Font.system(size: 24, weight: .bold, design: .default)
        static let subtitle16 = Font.system(size: 16, weight: .regular, design: .default)
        static let button18 = Font.system(size: 18, weight: .bold, design: .default)
        static let caption13 = Font.system(size: 13, weight: .regular, design: .default)
    }
}

extension Color {
    init(hex: String, alpha: Double = 1.0) {
        let sanitized = hex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        self = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
