import SwiftUI

final class OnboardingViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var dontShowAgain: Bool = false

    let steps: [OnboardingStep] = OnboardingStep.allCases

    var currentStep: OnboardingStep {
        steps[currentIndex]
    }

    var isFirstStep: Bool {
        currentIndex == 0
    }

    var isLastStep: Bool {
        currentIndex == steps.count - 1
    }

    @discardableResult
    func moveToNextStep() -> Bool {
        guard !isLastStep else { return true }
        currentIndex += 1
        return false
    }

    func moveToPreviousStep() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    func jumpToSafetyStep() {
        guard let safetyIndex = steps.firstIndex(of: .safety) else { return }
        currentIndex = safetyIndex
    }
}
