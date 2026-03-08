# SSC Breathway Logic Spec (Readiness + Breathing)

- Version: v1.1
- Date: 2026-02-25
- Scope:
  - `Readiness Check` 이후 `Recommended Session`(Light/Standard) 결정 로직
  - `Breathing Play`의 `Inhale/Exhale` 위상, 세기 시각화, 폴백 로직
- Source of Truth: `docs/past/ssc_breath_service_prd.md`
  - FR-03 (Recommended Session)
  - FR-04 (Breathing 60s)
  - FR-38 / FR-39 / FR-40 (Inhale/Exhale intensity visualization + fallback)
  - 10.3 Adaptive Difficulty Score (ADS) Calculation Spec
  - 10.4 Level Selection State Machine
  - 10.5 Fallback Rules
  - 10.6 Breath Effort Visualization Spec
  - 12.4 Core Event Taxonomy

---

## 0. Rule IDs (R-01 ~ R-10)

- `R-01`: Severe 입력 시 `Light` 기본 추천 (FR-03)
- `R-02`: ADS 식은 `dyspnea*18 + fatigue*14 + max(0, rpe-5)*6` 가중치를 사용
- `R-03`: ADS는 `0...100` clamp
- `R-04`: 일관성 보너스는 `last7_completion_rate * 20`
- `R-05`: 우선순위 1: `consecutiveSafetyStops >= 2` 이면 `Light`
- `R-06`: 우선순위 2: `dyspnea == Severe(3)` 이면 `Light`
- `R-07`: 우선순위 3: `ADS < 45` 이면 `Light`, 그 외 `Standard`
- `R-08`: 제출 빌드 추천 출력은 `Light`/`Standard`만 사용
- `R-09`: 추천 결과는 `level_recommended` 이벤트로 기록 가능해야 함
- `R-10`: Readiness 입력 변경 시 추천은 즉시 재계산되어야 함

---

## 1. 목적

호흡기 사용자(COPD 포함)가 오늘 수행 가능한 강도(Recommended Session)와 호흡 수행 품질(Inhale/Exhale rhythm + effort band)을 안전하게 안내받도록, Readiness 로직과 Breathing 로직을 구현 가능한 형태로 고정한다.

---

## 2. 입력값 정의 (Readiness)

- `dyspnea`: 숨참 정도 (`0...3`)
  - `3`은 Severe에 해당
- `fatigue`: 피로 정도 (`0...3`)
- `last7_completion_rate`: 최근 7일 완료율 (`0.0...1.0`)
- `last_rpe_after`: 이전 세션 후 자각운동강도 (`0...10`)
- `consecutiveSafetyStops`: 연속 안전 중단 일수 (정수, 로컬 로그 기반)

---

## 3. ADS 계산식

```text
readiness = 100 - (dyspnea*18 + fatigue*14 + max(0, last_rpe_after-5)*6)
consistency_bonus = last7_completion_rate * 20
ADS_raw = readiness + consistency_bonus
ADS = clamp(ADS_raw, 0, 100)
```

---

## 4. 레벨 매핑 기준

- `Light`: `ADS < 45`
- `Standard`: `45 <= ADS <= 74`
- `Standard+`: `ADS >= 75`
  - 단, SSC 제출 빌드에서는 `Standard+`를 강도 증가에 사용하지 않고 UI 노출만 허용

---

## 5. Recommended Session 결정 우선순위

아래 우선순위로 최종 추천을 결정한다.

1. **안전 강제 규칙 우선 적용**
- `consecutiveSafetyStops >= 2` 이면 무조건 `Light`

2. **당일 Severe override 적용**
- `dyspnea == Severe(3)` 이면 무조건 `Light`
- FR-03 수용 기준: Severe 입력 시 라이트 루틴 기본 선택

3. **ADS 기반 기본 매핑 적용**
- 위 두 조건이 아니면 ADS로 매핑
- 제출 빌드 추천 결과는 최종적으로 `Light` 또는 `Standard`만 사용

---

## 6. 상태 전이 규칙 (Readiness State Machine)

- 기본 진입:
  - Readiness Check 완료 -> ADS 계산 -> Recommended Session 확정

- 진입 조건:
  - `Light`:
    - `dyspnea`가 Severe, 또는
    - `ADS < 45`, 또는
    - 연속 2일 safety stop
  - `Standard`:
    - `ADS >= 45` **AND** 당일 Severe 없음

- 세션 중 전환:
  - 사용자가 안전 중단을 입력하면 즉시 Recovery Guide로 전환
  - Recovery 후 선택:
    - `Restart with Light` (Light로 재시작)
    - `End for Today` (오늘 종료)

---

## 7. 구현용 의사코드 (Readiness)

```swift
func recommendedSession(
  dyspnea: Int,
  fatigue: Int,
  last7CompletionRate: Double,
  lastRPEAfter: Int,
  consecutiveSafetyStops: Int
) -> SessionLevel {
  if consecutiveSafetyStops >= 2 { return .light }
  if dyspnea >= 3 { return .light } // Severe override

  let readiness = 100 - (dyspnea * 18 + fatigue * 14 + max(0, lastRPEAfter - 5) * 6)
  let bonus = Int((last7CompletionRate * 20).rounded())
  let ads = min(max(readiness + bonus, 0), 100)

  if ads < 45 { return .light }
  return .standard
}
```

---

## 8. 이벤트 로깅 권장 포인트 (Readiness)

- `readiness_check_completed`
- `level_recommended` (payload: input values, ADS, recommended level)
- `mission_stopped_for_safety`
- `mission_restarted_after_recovery`

---

## 9. SSC 제출 빌드 기본값

- 추천 결과는 `Light` / `Standard` 2단계로 운영
- `Standard+`는 내부 계산 참고용 또는 UI 표기용으로만 유지
- 오프라인/로컬 저장 기반(`UserDefaults`/로컬 JSON)에서 동일하게 계산 가능해야 함

---

## 10. Breathing Logic IDs (BR-01 ~ BR-20)

- `BR-01`: Breathing 세션 총 길이는 60초 고정 (`FR-04`).
- `BR-02`: 위상 기본 프로파일은 `4초 Inhale + 6초 Exhale`.
- `BR-03`: 위상 전환은 단조 증가 시계(`ContinuousClock`) 기반.
- `BR-04`: 마이크 허용 시 `AVAudioEngine.inputNode` tap으로 실시간 샘플 획득.
- `BR-05`: 내부 샘플링 목표는 50ms(20Hz) 처리, UI 반영은 200ms 이내 (`FR-38`).
- `BR-06`: 입력 dB는 `amp = 10^(dB/20)`로 변환.
- `BR-07`: EMA 스무딩 `alpha = 0.25` 적용.
- `BR-08`: 시작 6초 구간에서 `floor`/`peak_ref` 캘리브레이션.
- `BR-09`: `effort = clamp((amp - floor) / max(EPS, peak_ref - floor), 0...1)`.
- `BR-10`: 밴드 매핑 `Gentle(0.00~0.32)`, `Steady(0.33~0.66)`, `Strong(0.67~1.00)`.
- `BR-11`: 밴드 깜빡임 방지를 위해 300ms 히스테리시스 적용.
- `BR-12`: `Steady` 3초 연속 유지 시 1회 성취 이벤트(`FR-39`).
- `BR-13`: 마이크 권한 거부/실패 시 `Rhythm-only mode`로 즉시 폴백(`FR-40`).
- `BR-14`: 폴백에서도 60초 루프/위상 가이드/완료 플로우는 유지.
- `BR-15`: Reduce Motion 활성 시 3D/대규모 스케일 모션 제거.
- `BR-16`: 위상 변화 피드백은 `sensoryFeedback`로 상태 기반 제공.
- `BR-17`: 로깅 이벤트는 PRD taxonomy를 따름 (`breath_effort_band_changed` 등).
- `BR-18`: 의료 진단 목적 아님 문구와 코칭용 지표 제한을 명시.
- `BR-19`: 세션 요약은 `avgInhaleEffort`, `avgExhaleEffort`, `timeInSteadyBandSec`.
- `BR-20`: 모든 계산/저장은 오프라인 로컬 동작만 허용.

---

## 11. Breathing State Machine

- `idle`:
  - Breathing 시작 전 상태
- `preflight`:
  - 오디오 권한 확인 + 세션 설정
  - 권한 허용/세션 활성 성공 시 `capturing`
  - 실패 시 `rhythmOnly`
- `capturing`:
  - 위상 스케줄러 + 오디오 샘플 처리 동시 실행
  - 60초 완료 시 `completed`
  - 사용자 중단 시 `stoppedForSafety`
- `rhythmOnly`:
  - 마이크 입력 없이 위상/타이머만 유지
  - 60초 완료 시 `completed`
- `paused`:
  - 사용자 pause 상태 (타이머/샘플 처리 정지)
- `completed`:
  - 요약 산출(`BreathIntensitySummary`) + 완료 이벤트
- `stoppedForSafety`:
  - Recovery Guide로 전이

---

## 12. Inhale/Exhale Phase Scheduler

### 12.1 고정 설정

- `total = 60s`
- `inhale = 4s`
- `exhale = 6s`
- `cycle = inhale + exhale = 10s`
- 총 `6 cycle` 기준

### 12.2 위상 계산식

`elapsedSec`를 0~60 사이로 clamp 후 다음을 계산:

```text
offset = elapsedSec mod 10
phase = inhale if offset < 4 else exhale
phaseProgress =
  offset / 4            (inhale)
  (offset - 4) / 6      (exhale)
remaining = 60 - elapsedSec
```

### 12.3 시간 소스/렌더링

- 세션 기준 시간원: `ContinuousClock` (`BR-03`)
- UI 갱신 스케줄: `TimelineView(.periodic(..., by: 0.2))` (`BR-05`)
- 내부 오디오 샘플 처리는 20Hz(50ms)로 별도 누적 후 UI에 200ms 주기로 반영

---

## 13. Audio Capture & Effort Pipeline

### 13.1 Allowed APIs for App Playground (Cupertino Evidence)

- 오디오 캡처/권한:
  - `AVAudioEngine`: `apple-docs://avfaudio/documentation_avfaudio_avaudioengine`
  - `inputNode`: `apple-docs://avfaudio/documentation_avfaudio_avaudioengine_inputnode`
  - `installTap(onBus:...)`: `apple-docs://avfaudio/documentation_avfaudio_avaudionode_installtap_onbus_buffersize_format_block_83c5847b`
  - `setCategory(_:mode:options:)`: `apple-docs://avfaudio/documentation_avfaudio_avaudiosession_setcategory_mode_options_cbe1a0e5`
  - `setActive(_:options:)`: `apple-docs://avfaudio/documentation_avfaudio_avaudiosession_setactive_options_ca1150c6`
  - `requestRecordPermission` (iOS17+): `apple-docs://avfaudio/documentation_avfaudio_avaudioapplication_requestrecordpermission_completionhandler_2b8d813d`
  - 레거시 권한 API: `apple-docs://avfaudio/documentation_avfaudio_avaudiosession_requestrecordpermission_42e6ddcc`
- 시간/렌더링:
  - `TimelineView`: `apple-docs://swiftui/documentation_swiftui_timelineview`
  - `ContinuousClock`: `apple-docs://swift/documentation_swift_continuousclock`
- 인터랙션/접근성:
  - `sensoryFeedback(_:trigger:)`: `apple-docs://swiftui/documentation_swiftui_view_sensoryfeedback_trigger_09a6de74`
  - `accessibilityReduceMotion`: `apple-docs://swiftui/documentation_swiftui_environmentvalues_accessibilityreducemotion`
- iPadOS26 비주얼 컨텍스트:
  - `glassEffect(_:in:)`: `apple-docs://swiftui/documentation_swiftui_view_glasseffect_in_b34741bd`
  - `GlassEffectContainer`: `apple-docs://swiftui/documentation_swiftui_glasseffectcontainer`

### 13.2 오디오 세션 설정

1. `AVAudioSession.setCategory(_:mode:options:)` 선행
2. `AVAudioSession.setActive(true, options: [])`
3. 권한 요청:
   - iOS17+ 우선 `AVAudioApplication.requestRecordPermission()`
   - 하위 호환 `AVAudioSession.requestRecordPermission(_:)`

### 13.3 입력 샘플 획득 (Engine Tap)

1. `let engine = AVAudioEngine()`
2. `let input = engine.inputNode`
3. `let format = input.outputFormat(forBus: 0)`
4. `input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in ... }`
5. tap 블록에서 PCM 샘플 RMS -> dB -> amp 변환

### 13.4 정규화 파이프라인

```text
rms = sqrt(mean(samples^2))
dB = 20 * log10(max(rms, 1e-7))
amp = 10^(dB / 20)
smoothed = alpha * amp + (1 - alpha) * prevSmoothed   where alpha = 0.25
```

### 13.5 캘리브레이션

- 세션 시작 후 6초 동안 `smoothed` 샘플 축적
- `floor = p20(samples)` (20th percentile)
- `peak_ref = p95(samples)` (95th percentile)
- 안전 보정:
  - `floor >= 1e-4`
  - `peak_ref >= floor + 1e-3`

### 13.6 Effort 계산

```text
effort = clamp((smoothed - floor) / max(EPS, peak_ref - floor), 0, 1)
EPS = 1e-6
```

---

## 14. Band Mapping & Hysteresis

### 14.1 밴드 분류

- `Gentle`: `0.00...0.32`
- `Steady`: `0.33...0.66`
- `Strong`: `0.67...1.00`

### 14.2 히스테리시스 (300ms)

- `instantBand`와 현재 `stableBand`가 다르면 즉시 전환하지 않음
- `candidateBand`와 `candidateSince`를 기록
- 후보가 300ms 연속 유지될 때만 `stableBand` 전환
- `stableBand` 전환 시 `breath_effort_band_changed` 이벤트 발행

### 14.3 Steady streak 규칙

- `stableBand == .steady` 누적 시간을 `steadyRunSec`로 계산
- `steadyRunSec >= 3.0` && `steadyRewardFired == false`일 때:
  - `breath_effort_steady_streak_achieved` 1회 발행
  - `lighthouse_beam_stabilized` 1회 발행
  - `steadyRewardFired = true`

---

## 15. Fallback (Rhythm-only Mode)

### 15.1 진입 조건

다음 중 하나라도 충족하면 `rhythmOnly`:

- 마이크 권한 거부
- `AVAudioSession` 활성화 실패
- `AVAudioEngine.start()` 실패
- `inputNode` 포맷 무효(sample rate/channel count 0)
- tap 설치 실패

### 15.2 동작 규칙

- 60초 위상 스케줄은 동일 유지 (`BR-14`)
- intensity 기반 평가는 비활성화
- UI는 `Rhythm-only mode` 배지/문구 노출
- 이벤트 payload의 `mode = rhythmOnly`
- 핵심 루프(완료/중단/재시도)는 정상 동작 유지

---

## 16. Accessibility / Motion / Haptic

- `accessibilityReduceMotion == true`:
  - 3D 변형/대규모 스케일 애니메이션 제거
  - opacity/색상 전환 중심으로 대체 (`BR-15`)
- 위상 피드백:
  - `sensoryFeedback`를 phase 변화 trigger로 연결 (`BR-16`)
- 색상 단독 인코딩 금지:
  - phase/band는 아이콘 + 텍스트 + 색상 동시 표기
- Safety 버튼 터치 타깃:
  - 최소 72pt 규칙 유지

---

## 17. Event Contract (Breathing)

### 17.1 이벤트 목록

- `breathing_play_started`
- `breath_effort_band_changed`
- `breath_effort_steady_streak_achieved`
- `lighthouse_beam_stabilized`
- `breathing_play_completed`
- `mission_stopped_for_safety`

### 17.2 Payload 스키마

```swift
struct BreathingEventPayload {
  let phase: BreathPhase
  let band: BreathBand
  let effort: Double        // 0...1
  let elapsed: Duration
  let mode: BreathCaptureMode
}
```

- `breath_effort_band_changed`: `previousBand`, `newBand`, `elapsed`, `mode`
- `breath_effort_steady_streak_achieved`: `steadyRunSec`, `elapsed`, `mode`
- `lighthouse_beam_stabilized`: `elapsed`, `mode`
- `breathing_play_completed`: `durationSec`, `avgInhaleEffort`, `avgExhaleEffort`, `timeInSteadyBandSec`, `mode`

---

## 18. Implementation Pseudocode (SwiftUI + AVFAudio)

### 18.1 Implementation Contract (Public Types)

```swift
enum BreathPhase { case inhale, exhale }
enum BreathBand { case gentle, steady, strong }
enum BreathCaptureMode { case microphone, rhythmOnly }

struct BreathEffortSample {
  let t: Duration
  let phase: BreathPhase
  let effort: Double
  let band: BreathBand
}

struct BreathSessionConfig {
  let total: Duration = .seconds(60)
  let inhale: Duration = .seconds(4)
  let exhale: Duration = .seconds(6)
}

struct BreathIntensitySummary {
  let avgInhaleEffort: Double
  let avgExhaleEffort: Double
  let timeInSteadyBandSec: Double
}

protocol BreathSignalProvider {
  func start() async
  func stop()
  var mode: BreathCaptureMode { get }
}
```

### 18.2 세션 엔진 의사코드

```swift
@MainActor
final class BreathingSessionEngine {
  private let config = BreathSessionConfig()
  private let clock = ContinuousClock()
  private var startInstant: ContinuousClock.Instant?
  private var mode: BreathCaptureMode = .microphone

  private var smoothedAmp: Double = 0
  private let alpha: Double = 0.25
  private var calibrationSamples: [Double] = []
  private var floor: Double = 1e-4
  private var peakRef: Double = 0.1

  private var stableBand: BreathBand = .gentle
  private var candidateBand: BreathBand?
  private var candidateSince: Duration = .zero
  private var steadyRunSec: Double = 0
  private var steadyRewardFired = false

  func start() async {
    startInstant = clock.now
    let permitted = await requestMicrophonePermission()
    if permitted, await configureAndStartAudioEngine() {
      mode = .microphone
    } else {
      mode = .rhythmOnly
    }
    emit("breathing_play_started")
  }

  func tick(now: ContinuousClock.Instant) -> BreathEffortSample {
    let elapsed = duration(from: startInstant, to: now).clamped(to: .zero ... .seconds(60))
    let phase = phaseAt(elapsed)

    let effort: Double = {
      if mode == .rhythmOnly { return 0.5 }
      return normalizedEffort(from: smoothedAmp, floor: floor, peakRef: peakRef)
    }()

    let instantBand = classify(effort)
    let band = updateBandWithHysteresis(instantBand, elapsed: elapsed, hold: .milliseconds(300))
    updateSteadyStreak(band: band, delta: 0.2)

    return BreathEffortSample(t: elapsed, phase: phase, effort: effort, band: band)
  }

  func complete() -> BreathIntensitySummary {
    stopAudioEngineIfNeeded()
    emit("breathing_play_completed")
    return summarize()
  }
}
```

### 18.3 SwiftUI 바인딩 포인트

- `TimelineView(.periodic(..., by: 0.2))`에서 `tick()` 호출
- `@Environment(\.accessibilityReduceMotion)`로 모션 축소 분기
- `.sensoryFeedback(_:trigger:)`를 phase/band 변화 trigger에 연결

---

## 19. Validation Matrix

| Case ID | 시나리오 | 입력/조건 | 기대 결과 | 관련 Rule |
| --- | --- | --- | --- | --- |
| B-01 | 60초 세션 위상 누적 검증 | 기본 설정(4/6) | 60초 종료, 위상 누적 합 60초 일치 | BR-01, BR-02 |
| B-02 | UI 갱신 주기 검증 | 샘플 50ms 입력 | UI 반영 지연 <= 200ms | BR-05 |
| B-03 | effort 범위 검증 | 극단 입력(매우 작음/큼) | effort가 항상 0...1 | BR-09 |
| B-04 | 밴드 경계값 검증 | 0.32/0.33/0.66/0.67 | Gentle/Steady/Steady/Strong | BR-10 |
| B-05 | 히스테리시스 검증 | 100ms 노이즈 점프 반복 | stableBand 급변 억제 | BR-11 |
| B-06 | Steady streak 보상 검증 | steady 3초 유지 | 성취 이벤트 1회만 발행 | BR-12 |
| B-07 | 권한 거부 폴백 검증 | 마이크 deny | 즉시 Rhythm-only, 세션 지속 | BR-13, BR-14 |
| B-08 | Reduce Motion 검증 | Reduce Motion ON | 기능 동일, 과도 모션 제거 | BR-15 |
| B-09 | 종료 요약 검증 | 정상 완료 | avgInhale/avgExhale/timeInSteady 계산 | BR-19 |
| B-10 | 오프라인 검증 | 비행기 모드 | 동일 계산/이벤트 동작 | BR-20 |

---

## 20. 구현 전제/기본값

1. 현재 범위는 문서 업데이트이며, 코드 구현은 다음 단계에서 진행한다.
2. Breathing 기본 위상은 `4s Inhale / 6s Exhale`로 고정한다.
3. 오디오 입력은 `AVAudioEngine tap`을 기본 경로로 채택한다.
4. Rule ID는 `R-*`(Readiness)와 `BR-*`(Breathing)로 분리 운영한다.
5. iPadOS26/SwiftUI App Playground 기준 API만 허용한다.
6. 구현 단계에서 `NSMicrophoneUsageDescription`은 반드시 포함한다.
