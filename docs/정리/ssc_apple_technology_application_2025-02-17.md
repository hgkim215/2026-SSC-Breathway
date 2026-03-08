# Swift Student Challenge 기술 적용 정리 (기준일: 2025-02-17)

## 1) 기준일 관점의 SSC 맥락

- 목표: `3분 내 체험 가능한 오프라인 App Playground` 완성도 확보
- 2025 라운드 일정(참고):
  - 접수 오픈: `2025-02-03`
  - 접수 마감: `2025-02-23`

## 2) 서비스 문서 기준

- 대상 문서: `docs/ssc_breath_core_mvp_strategy.md`
- 핵심 범위:
  - `호흡 운동 중심` + `저강도 집 운동 1종` 보조
  - 안전 가드레일
  - 오프라인 동작
  - 접근성(Dynamic Type, VoiceOver, 큰 터치 영역)

## 3) 추천 Apple Technology (우선순위)

### 1. SwiftUI (필수)

- 적용 이유:
  - 3분 데모에서 화면 전환, 애니메이션, 인터랙션 완성도 확보에 가장 유리
- 적용 포인트:
  - `Home` 1탭 시작 흐름
  - `Pre-check` 상태 분기 UI
  - `Breathing Mission` 리듬 가이드 애니메이션
  - `Result`, `Progress` 시각 구성

### 2. SwiftData (필수)

- 적용 이유:
  - 네트워크 없이 데이터 지속성 확보 가능
- 적용 포인트:
  - 문서의 로컬 모델 직접 반영:
    - `Session(date, type, completed, duration, preCheck, postCheck)`
    - `Streak(currentDays, recoveryToken)`
    - `Achievement(id, unlockedAt)`
  - `XP`, `streak`, `주간 완료 기록` 저장

### 3. Core Haptics + sensoryFeedback (강력 추천)

- 적용 이유:
  - 호흡 페이즈 전환을 촉각으로 전달해 몰입/접근성 강화
- 적용 포인트:
  - inhale/hold/exhale 전환 시 햅틱 패턴
  - 위험 신호 선택 시 경고 햅틱

### 4. AVFAudio (강력 추천)

- 적용 이유:
  - 시선 고정이 어려운 사용자에게 음성 코칭 제공
- 적용 포인트:
  - `Inhale... Exhale slowly...` 음성 큐
  - 미션 시작/완료 사운드 피드백
  - `I Need Help` 탭 시 안내 음성

### 5. Accessibility APIs + HIG Accessibility (필수)

- 적용 이유:
  - 심사 항목의 Inclusivity 및 Social Impact를 직접 강화
- 적용 포인트:
  - Dynamic Type 완전 대응
  - VoiceOver 라벨/힌트 구성
  - 큰 터치 영역
  - Reduce Motion/색 대비 대응

### 6. Swift Charts (추천)

- 적용 이유:
  - 지속성 지표를 짧은 시간에 직관적으로 전달 가능
- 적용 포인트:
  - `Progress` 화면에 주간 완료율, streak 추이 시각화
  - 안전 중단 기록 최소 차트 표시

### 7. UserNotifications (선택)

- 적용 이유:
  - "매일 1~2분 실천" 루틴 유지 지원
- 적용 포인트:
  - 로컬 리마인더 알림(네트워크 불필요)

### 8. App Intents (선택, 여유 시)

- 적용 이유:
  - 기술적 완성도/창의성 포인트 추가 가능
- 적용 포인트:
  - Siri/Shortcuts에서 오늘 미션 바로 시작

## 4) `docs/ssc_breath_core_mvp_strategy.md` 화면별 매핑

1. `Home`
- SwiftUI + Accessibility
- 오늘 미션 카드, 컨디션 상태, 시작 CTA

2. `Pre-check`
- SwiftUI + SwiftData
- 상태 입력 후 일반/라이트 미션 분기

3. `Breathing Mission`
- SwiftUI + Core Haptics + AVFAudio
- 리듬 애니메이션, 촉각/음성 큐, 큰 중단 버튼, 안전 버튼

4. `Light Movement`
- SwiftUI + AVFAudio
- 60초 의자 루틴 가이드 및 완료 처리

5. `Result`
- SwiftUI + SwiftData
- 완료 시간, XP, streak, 피드백 문구 표시

6. `Progress`
- Swift Charts + SwiftData
- 주간 캘린더/완료율/안전 중단 기록 시각화

## 5) 구현 우선순위 제안 (MVP 기준)

1. `SwiftUI + SwiftData + Accessibility`로 핵심 루프 완성
2. `Core Haptics + AVFAudio`로 호흡 경험 강화
3. `Swift Charts`로 진행도 시각화
4. 일정 여유 시 `UserNotifications`, `App Intents` 추가

## 6) 참고 링크

- Swift Student Challenge
  - https://developer.apple.com/swift-student-challenge/
  - https://developer.apple.com/swift-student-challenge/eligibility/
  - https://developer.apple.com/swift-student-challenge/policy/
- 2025 공지
  - https://developer.apple.com/hello/january25/
  - https://developer.apple.com/hello/february25/
- 기술 문서
  - https://developer.apple.com/swiftui/
  - https://developer.apple.com/documentation/swiftdata/modelcontainer
  - https://developer.apple.com/documentation/CoreHaptics
  - https://developer.apple.com/documentation/avfaudio/avaudiofile
  - https://developer.apple.com/documentation/technologyoverviews/audio-and-music
  - https://developer.apple.com/documentation/accessibility
  - https://developer.apple.com/design/human-interface-guidelines/accessibility
  - https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications
  - https://developer.apple.com/documentation/AppIntents/app-intents
