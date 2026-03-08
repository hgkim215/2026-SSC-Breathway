# Breathway

`100% AI Agent-Built · Safety-First Breathing Recovery Routine`

Breathway is an iPad-first Swift App Playground designed for people with COPD or chronic respiratory discomfort who need a short, repeatable daily routine. The current build focuses on a calm, safety-first mission loop that combines guided breathing, gentle sit-to-stand movement, and lightweight progress tracking without requiring a network connection.

## Overview

- Platform: iPadOS App Playground (`.swiftpm`)
- UI: SwiftUI, landscape-only iPad experience
- Runtime target: iOS 26 / Xcode 26+ / Swift Playgrounds 4.6+
- Core principle: small, repeatable recovery actions over intense exercise
- Offline posture: the core mission loop runs locally without backend dependencies

## Current User Flow

The implementation in `Breathway.swiftpm` currently follows this sequence:

1. Onboarding
2. Home
3. Readiness Check
4. Breathing Guide or Breathing Session
5. Sit-to-Stand Guide
6. Sit-to-Stand Session
7. Daily Result
8. Weekly Progress

## Implemented Features

### 1. Home and Daily Mission Entry

- A single primary CTA starts the daily mission from the home screen.
- The home screen shows:
  - current streak
  - current week completion capsules
  - respiratory safety disclaimer
  - background music toggle
  - onboarding re-entry

### 2. Readiness-Based Session Recommendation

- Breathway uses a local ADS-style readiness calculation to recommend `Light` or `Standard`.
- Inputs include:
  - breathlessness
  - fatigue
  - confidence
  - recent completion rate
  - previous exertion context
  - consecutive safety-stop history
- Severe states or repeated safety stops force a lighter recommendation.

### 3. Guided Breathing Session

- Default breathing session length is `60 seconds`.
- Session configuration changes by recommendation:
  - `Light`: inhale 5s / exhale 5s
  - `Standard`: inhale 4s / exhale 6s
- The breathing engine attempts microphone-based effort tracking through `AVAudioEngine`.
- If microphone permission is denied or capture fails, the app automatically falls back to `rhythm-only` mode so the mission can continue.
- During the session, the user can:
  - pause or resume
  - end the mission
  - trigger a recovery flow when they need rest

### 4. Sit-to-Stand Movement Session

- The current implementation uses a `90-second` sit-to-stand phase.
- Session configuration changes by recommendation:
  - `Light`: stand 4s / sit 5s / goal 10 reps
  - `Standard`: stand 3s / sit 3s / goal 15 reps
- The movement flow supports:
  - pause and resume
  - early ending
  - safety stop and recovery sheet

### 5. Result and Progress Tracking

- Mission completion updates the home streak immediately.
- Weekly progress summarizes:
  - streak
  - week completion ratio
  - safety-stop count
  - recent safety log lines
- Breathing and movement events are stored locally for progress review.

### 6. Motivational Tips with Safe Fallback

- Home and progress screens can generate short supportive tips.
- When `FoundationModels` is available, the app can request fresh on-device wording.
- If that path is unavailable, the app falls back to built-in English tip pools so the experience remains usable offline.

## Safety and Accessibility

- The UI includes a persistent medical disclaimer.
- Safety-first exit and recovery paths are built into both breathing and movement flows.
- The codebase includes:
  - accessibility labels across core controls
  - adjustable readiness controls
  - haptic feedback for phase changes and safety states
  - reduced-motion handling in active session screens
  - large tap targets and dynamic text scaling support

## Offline and Local Data Model

Breathway is intentionally local-first for SSC-style delivery:

- No account system
- No cloud sync
- No backend API dependency for the core loop
- User data is stored with `UserDefaults` and local Codable models

Currently persisted local state includes:

- onboarding visibility preferences
- guide re-entry preferences
- background music preference
- completed mission days for streaks
- progress session events
- analytics event records
- recent tip signatures to avoid repetition

## Tech Stack

- Swift 6
- SwiftUI
- App Playground package structure (`Breathway.swiftpm`)
- `AVFAudio` for microphone capture and background audio
- optional `FoundationModels` integration with built-in fallback behavior
- local persistence with `Codable` + `UserDefaults`

## Project Structure

```text
SSC/
├── Breathway.swiftpm/
│   ├── BreathwayApp.swift
│   ├── AppRootView.swift
│   ├── DesignSystem/
│   ├── Features/
│   │   ├── BreathGuide/
│   │   ├── Breathing/
│   │   ├── Home/
│   │   ├── Move/
│   │   ├── Onboarding/
│   │   ├── Progress/
│   │   ├── Readiness/
│   │   ├── Recovery/
│   │   ├── Result/
│   │   └── Tips/
│   ├── Resources/
│   └── Shared/
├── docs/
├── Breathway.pen
└── Breathway.swiftpm.zip
```

## Key Files to Read First

- `Breathway.swiftpm/BreathwayApp.swift`
- `Breathway.swiftpm/AppRootView.swift`
- `Breathway.swiftpm/Features/Readiness/ReadinessViewModel.swift`
- `Breathway.swiftpm/Features/Breathing/BreathingSessionEngine.swift`
- `Breathway.swiftpm/Features/Move/MoveSessionEngine.swift`
- `Breathway.swiftpm/Features/Progress/ProgressStore.swift`

## Documentation

- Product summary: [`docs/SSC_Breathway_PRD.md`](docs/SSC_Breathway_PRD.md)
- Logic spec: [`docs/SSC_Breathway_LOGIC.md`](docs/SSC_Breathway_LOGIC.md)
- Submission checklist: [`docs/SSC_CHECKLIST.md`](docs/SSC_CHECKLIST.md)
- Credits template: [`docs/정리/CREDITS.md`](docs/%EC%A0%95%EB%A6%AC/CREDITS.md)

Note: some documents in `docs/past/` and `docs/정리/` reflect earlier planning, research, or condensed PRD snapshots. When there is a mismatch, the Swift code in `Breathway.swiftpm` is the most reliable source for current behavior.

## Run Locally

### Xcode

1. Open `Breathway.swiftpm` in Xcode 26 or later.
2. Select the `Breathway` scheme.
3. Run on an iPad simulator or supported device in landscape mode.

### Command Line

From the `Breathway.swiftpm` directory:

```bash
xcodebuild -scheme Breathway -destination 'generic/platform=iOS' build
```

## Repository Purpose

This repository contains:

- the working App Playground submission project
- planning and logic documents for the SSC entry
- bundled assets used by the app
- design source material (`Breathway.pen`)

## Disclaimer

Breathway is a habit-support and guided wellness prototype. It does not provide medical diagnosis or treatment.
