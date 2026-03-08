# SSC 전략 문서: 호흡 운동 코어 집중형 MVP (독립본)

> 작성일: 2026-02-17  
> 목적: Swift Student Challenge 제출작의 최종 범위를 `호흡 운동 중심`으로 확정하고, 3분 심사 기준에 맞는 구현/데모 전략을 정리

---

## 1. 최종 의사결정

- 선택: `호흡 운동`에 집중하고, `저강도 집 운동 1개`를 보조 기능으로만 포함
- 이유:
  - 3분 내 핵심 가치 전달 가능성 극대화
  - 기능 분산으로 인한 완성도 저하 리스크 감소
  - 사회적 영향/포용성/접근성 스토리를 가장 강하게 전달 가능

---

## 2. 문제 정의 (Current vs Desired)

- Current:
  - 호흡기 환자는 운동 필요성을 알아도 숨참과 피로 때문에 실천을 중단하기 쉽다.
  - 루틴이 길거나 복잡하면 시작 자체를 미루게 된다.
- Desired:
  - 환자가 `매일 1~2분`이라도 안전하게 실행할 수 있는 호흡 루틴을 유지한다.
  - 앱이 "측정기"가 아니라 "실천 코치" 역할을 수행한다.

---

## 3. MVP Scope (Must / Should / Could / Out)

## Must Have

- 60~120초 `리듬 호흡 미션` 1종 (핵심)
- `상대강도 피드백` (Exhale Quality Ring: Gentle/Steady/Strong)
- `Dyspnea Recovery Protocol` (숨참 발생 시 45~60초 회복 스크립트)
- `One-Thumb Safe Mode` (한 손 조작용 초단순 UI: 멈춤/회복/도움)
- 운동 전/후 `자가 상태 체크` (숨참, 어지러움, 피로)
- `안전 가드레일` (위험 신호 시 즉시 중단 + 응급 안내)
- `지속 동기` (XP, streak, 주간 완료 캘린더)
- 오프라인 완전 동작 + 접근성(Dynamic Type, VoiceOver, 큰 터치 영역)

## Should Have

- `생활동작 재활 미션(ADL Breath Pacing)` 1종
  - 예: 의자에서 일어나기/실내 1분 걷기 + 들숨/날숨 템포 결합
- 상태가 나쁜 날 자동 `라이트 미션` 제안

## Could Have

- 1줄 컨디션 메모
- 성취 배지 3개

## Out of Scope

- 실제 폐기능/유량 측정
- 외부 센서/병원 연동
- 임상 수치(L/min, FEV1 등) 제공
- 고급 분석/소셜 기능

---

## 4. 3분 심사 데모 시나리오

- 0:00~0:25: 문제 소개 (숨이 차서 운동 지속이 어려운 현실)
- 0:25~1:20: 호흡 미션 + Exhale Quality Ring 실시간 실행 (핵심 경험)
- 1:20~1:50: 숨참 상황 재현 -> Dyspnea Recovery Protocol 실행
- 1:50~2:20: ADL Breath Pacing 미션(저강도 생활동작) 실행
- 2:20~2:40: 완료 보상(XP/streak/캘린더)
- 2:40~3:00: 안전 가드레일 + 접근성 포인트 설명

데모 원칙:
- 1탭으로 시작 가능
- 텍스트 설명 최소화, 즉시 체험 중심
- 실패/중단 상황도 자연스럽게 처리되는지 보여주기

---

## 5. 화면 IA (6 Screen)

1. `Home`
- 오늘의 미션, 컨디션 상태, 시작 버튼

2. `Pre-check`
- 숨참/어지러움 체크
- 상태에 따라 일반/라이트 미션 분기

3. `Breathing Mission`
- 리듬 가이드 애니메이션 (inhale/hold/exhale)
- `Exhale Quality Ring` 실시간 표시 (상대강도/안정성 시각화)
- 숨참 감지/자가 보고 시 `Dyspnea Recovery Protocol` 즉시 전환
- `One-Thumb Safe Mode` 진입 버튼(큰 CTA)
- 큰 중단 버튼 + 안전 도움 버튼

4. `Light Movement`
- `ADL Breath Pacing` 60초 루틴(일상동작 + 호흡 템포 가이드)

5. `Result`
- 완료 시간, XP, streak, 오늘의 한 줄 피드백

6. `Progress`
- 주간 캘린더, 완료율, 안전 알림 기록

---

## 6. 화면 카피 (영문, 제출용 바로 사용 가능)

## Home

- Title: `Breathe Better, One Minute at a Time`
- CTA: `Start Today’s Mission`
- Secondary: `Need a gentler session?`

## Pre-check

- Prompt: `How do you feel right now?`
- Options: `Mild breathlessness / Moderate / Severe`
- Safety note: `If you feel chest pain or dizziness, stop and seek help.`

## Breathing Mission

- Guide: `Inhale... Exhale slowly...`
- CTA: `Pause`
- Emergency CTA: `I Need Help`

## Light Movement

- Guide: `Sit to stand with paced breathing, 60 seconds`
- CTA: `I’m Done`

## Result

- Message: `Great work. You completed today’s session.`
- XP line: `+20 XP`
- Streak line: `3-day streak`

## Progress

- Title: `Your Weekly Progress`
- Metric label: `Sessions Completed`
- Encouragement: `Consistency beats intensity.`

---

## 7. 게임화 규칙 (단순하고 명확하게)

- XP 지급:
  - 호흡 미션 완료: +20
  - 라이트 미션 완료: +10
  - 안전 중단 후 재시도: +5 (실패 페널티 없음)
- Streak:
  - 하루 1회라도 완료하면 유지
  - 미완료 시 0으로 초기화 대신 `Recovery Day` 1회 제공
- 피드백 톤:
  - "강도"보다 "지속" 강화 메시지 사용

---

## 8. 안전/윤리 가이드

- 의료 대체 금지 문구 고정 노출:
  - `This app does not provide medical diagnosis or treatment.`
- 위험 신호 선택 시:
  - 즉시 미션 중단
  - `Dyspnea Recovery Protocol` 자동 실행(멈춤-자세-긴 날숨-상태 재확인)
  - 응급 대응 안내
- 금지:
  - 임상적 효능 단정 문구
  - 의료기기처럼 보이는 수치 표현

---

## 9. 데이터/기술 최소 설계

- Local model:
  - Session(date, type, completed, duration, preCheck, postCheck)
  - BreathSample(timestamp, phase, powerNorm, duration, stability)
  - CalibrationProfile(gentleBaseline, strongBaseline, updatedAt)
  - Streak(currentDays, recoveryToken)
  - Achievement(id, unlockedAt)
- 상대강도 계산:
  - `AVAudioRecorder` 미터링 기반(absolute 의료수치 아님)
  - 날숨 에너지 + 지속시간 + 안정성 결합
  - 출력 밴드: `Gentle / Steady / Strong`
- 저장:
  - SwiftData 또는 로컬 JSON
- 네트워크:
  - 사용하지 않음 (SSC 오프라인 심사 대응)

---

## 10. 2주 구현 플랜

## Week 1

- Day 1: IA 확정 + 디자인 토큰 정의
- Day 2: Home/Pre-check 화면 구현
- Day 3: Breathing Mission 애니메이션/타이머 구현
- Day 4: Result/Progress 화면 구현
- Day 5: 로컬 저장 + XP/streak 연결
- Day 6~7: 접근성(폰트/보이스오버/터치 영역) 점검

## Week 2

- Day 8: Light Movement 1종 추가
- Day 9: 안전 플로우(중단/응급 안내) 완성
- Day 10: 영문 카피/온보딩 문구 정리
- Day 11: 3분 데모 스크립트 1차
- Day 12: 사용자 테스트 5명
- Day 13: 개선 반영 + 버그 수정
- Day 14: 제출 패키징/최종 리허설

---

## 11. 심사 항목 매핑

- Innovation:
  - 절대 의료측정 대신 `개인 기준 상대강도 시각 피드백` + 회복 프로토콜
- Creativity:
  - 리듬/모션 + Exhale Quality Ring + ADL Breath Pacing 결합의 재활 경험
- Social Impact:
  - 실제 환자의 숨참/일상동작 장벽을 회복 중심 플로우로 직접 해결
- Inclusivity:
  - One-Thumb Safe Mode + 큰 UI + 저자극 인터랙션 + 접근성 기능

---

## 12. Submission Readiness Checklist

- [ ] 첫 실행 후 30초 안에 미션 시작 가능
- [ ] 2분 이내 핵심 루프(체크 -> 호흡 -> 결과) 완료
- [ ] 위험 상황 중단 플로우 정상 동작
- [ ] 캘리브레이션 후 Gentle/Steady/Strong 표시 정상 동작
- [ ] 숨참 재현 시 Dyspnea Recovery Protocol 즉시 전환
- [ ] One-Thumb Safe Mode(큰 버튼 3개) 한 손 조작 검증
- [ ] 네트워크 없이 3분 데모 완전 재현 가능
- [ ] 모든 핵심 문구 영어로 제공
- [ ] `This app is not a medical device...` 문구 고정 노출
- [ ] 접근성 점검(VoiceOver/Dynamic Type/Color contrast) 완료

---

## 13. 다음 작성 권장 문서

- `ssc_demo_script.md`: 발표 대본(영문/국문)
- `ssc_ui_copy_master.md`: 화면별 카피 확정본
- `ssc_test_protocol.md`: 5인 사용성 테스트 시트
