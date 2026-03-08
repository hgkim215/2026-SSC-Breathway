import Foundation

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case why
    case how
    case safety
    case personalizeStart

    var id: Int { rawValue }

    var penScreenName: String {
        switch self {
        case .why:
            return "Screen/Onboarding_iPad_01_Why"
        case .how:
            return "Screen/Onboarding_iPad_02_How"
        case .safety:
            return "Screen/Onboarding_iPad_03_Safety"
        case .personalizeStart:
            return "Screen/Onboarding_iPad_04_PersonalizeStart"
        }
    }

    var title: String {
        switch self {
        case .why:
            return "Start Small. Keep Moving."
        case .how:
            return "How Your Daily Loop Works"
        case .safety:
            return "Safety First, Always"
        case .personalizeStart:
            return "Personalize and Start"
        }
    }

    var subtitle: String {
        switch self {
        case .why:
            return "Breathway helps you build a short breathing and movement habit in under three minutes."
        case .how:
            return "Follow one simple sequence: check-in, breathing rhythm, then sit-to-stand with guided pacing."
        case .safety:
            return "You can stop or skip movement anytime if symptoms worsen. Safety decisions are always respected."
        case .personalizeStart:
            return "Review your routine once, then decide whether onboarding should appear automatically on next launch."
        }
    }

    var primaryButtonTitle: String {
        switch self {
        case .personalizeStart:
            return "Start Today's Mission"
        default:
            return "Next"
        }
    }
}
