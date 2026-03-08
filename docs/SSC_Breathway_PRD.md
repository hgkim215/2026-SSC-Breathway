# SSC Breathway PRD (Core)

- Version: v1.1 (Condensed)
- Date: 2026-02-25
- Product: `Breathway`
- Source: `docs/ssc_breath_service_prd.md` (핵심 항목만 요약)

## 1. Product Summary

`Breathway`는 COPD 및 만성 호흡기 불편 사용자가 매일 2~3분 루틴(호흡 + 저강도 움직임)을 끊기지 않게 지속하도록 돕는 iPad 앱이다.

핵심 가치:
- 완벽한 운동이 아니라, 매일 이어지는 작은 실천
- 안전 중단과 재시작을 전제로 한 재활 습관 형성

## 2. Submission Constraints (SSC)

- Platform: iPadOS, Landscape only
- Package: App Playground (`.swiftpm`) ZIP 1개
- Size: ZIP `<= 25MB`
- Runtime: Swift Playground 4.6 또는 Xcode 26+
- Offline: 핵심 루프 100% 오프라인 동작
- Language: 영어 콘텐츠 기준
- Resources: 이미지/사운드/카피/데이터 전부 로컬 번들 포함
- Credits: 외부 코드/에셋 사용 시 `docs/CREDITS.md` 필수

## 3. Problem and Users

문제:
- 사용자는 운동 필요성을 알지만 숨참/피로/지루함 때문에 루틴을 중단한다.

Primary user:
- COPD 환자 및 만성 호흡기 불편 사용자

Secondary user:
- 보호자/가족

## 4. Product Goals / Non-goals

Goals:
- 3분 데모 내 핵심 가치 전달
- 1일 1회 루틴 시작/완료 장벽 최소화
- 안전한 재시작 경험 제공
- 접근성 기본 내장 (VoiceOver, Dynamic Type, 큰 터치 타깃)

Non-goals:
- 진단/치료/처방 의사결정
- 외부 센서/병원 시스템 연동
- 소셜 피드/랭킹 중심 기능
- 클라우드 계정/동기화

## 5. MVP Scope

Must-have:
- 루프: `Home -> Readiness Check -> Breathing(60s) -> Move(45s, Sit-to-Stand) -> Result`
- 난이도 제안: `Light` / `Standard` 자동 추천
- Breathing 진입 가이드(하이브리드): 첫 진입은 사전 설명 스크린, 재진입은 요약 바텀시트 또는 즉시 시작
- Safety controls: Pause / Resume / Stop / I feel unwell
- Recovery Guide: 즉시 중단 후 재시작 또는 종료
- XP/Streak 즉시 반영
- 최근 7일 진행 상태 표시
- 로컬 저장 (세션/진행/안전 이벤트)

Should-have:
- 테마 3종 순환
- 주간 목표 배지
- 로컬 알림 리마인더(옵트인)

Out of scope:
- 의료 정확도 주장
- 온라인 필수 기능

## 6. Core UX Principles

- 첫 5초에 주 CTA(`Start Today's Mission`)가 가장 먼저 보여야 한다.
- 첫 20초 내 사용자가 “내 상태 확인 -> 오늘 루틴 시작” 구조를 이해해야 한다.
- 핵심 행동은 화면당 1개로 명확해야 한다.
- 미션 안내는 학습과 속도를 함께 만족해야 한다(첫 진입 충분한 설명, 재진입 최소 마찰).
- 실패 낙인 대신 재시도 중심 카피를 유지한다.

## 7. P0 Functional Requirements (Condensed)

- Home에서 1탭으로 시작 가능
- Readiness Check(숨참/피로/자신감) 입력 가능
- Severe 또는 저준비도는 `Light` 자동 제안
- Breathing Play 60초 타이머 완료 가능
- Breathing 첫 진입 시 사전 설명 스크린 노출(호흡 리듬, Exhale/Inhale 순서, 안전 중단 안내, 1사이클 미리보기)
- Breathing 재진입 시 요약 바텀시트 또는 즉시 시작 제공
- `Don't show again` 저장 및 Settings에서 `Breathing Guide` 재보기 제공
- Move Play 45초 Sit-to-Stand 완료 가능
- Safety 입력 시 1초 내 즉시 중단
- Recovery Guide 즉시 진입 + 2탭 내 재시작
- Result에서 완료/소요시간/다음 행동 인지 가능
- XP/Streak 결과 진입 후 1초 내 반영
- 오프라인에서 핵심 루프 완주 가능
- 의료 대체 금지 문구(Home 또는 Result) 노출
- 마이크 거부 시 `Rhythm-only mode` 폴백 제공
- 핵심 접근성(VoiceOver, Dynamic Type, 대체 입력) 동작

## 8. Non-functional Quality Bar

- 반응성: 핵심 조작 시각 피드백 300ms 이내
- 안정성: 데모 차단 버그 0, 크래시 0
- 접근성: 일반 56pt / Safety 72pt 타깃
- 대비: 일반 4.5:1+, 안전 텍스트 7:1+
- 오프라인: 네트워크 의존 없음

## 9. Safety and Compliance

- 고정 문구: `This app does not provide medical diagnosis or treatment.`
- 증상 악화 시 즉시 중단
- Recovery flow: 멈춤 -> 자세 정렬 -> 긴 날숨 -> 상태 재확인
- 응급 상황 연락 안내 제공

## 10. Data (Minimal)

로컬 엔티티:
- Session
- MissionProfile
- BreathIntensitySummary
- WeeklySummary

저장:
- `Codable + UserDefaults/FileManager(JSON)`

## 11. Success Metrics (Core)

North Star:
- `WARD (Weekly Active Rehab Days)` = 주 5일 이상 루틴 완료 비율

Leading:
- 미션 시작률
- 세션 완료율
- 7일 재방문율
- Steady 밴드 유지 시간
- 중단 후 재시작 성공률

Guardrails:
- Safety stop 비율
- Day-2 이탈률

## 12. Demo Acceptance (Go/No-go)

Go:
- 3분 내 핵심 루프 완주
- 오프라인 완전 동작
- XP/Streak 즉시 반영
- Safety 중단/복귀 정상 동작
- SSC 제출 조건(.swiftpm, 25MB, 영어, 크레딧) 충족

No-go:
- 안전 중단 플로우 실패
- 3분 내 핵심 가치 전달 실패
- 접근성 핵심 경로 실패
