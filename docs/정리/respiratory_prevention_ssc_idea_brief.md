# 호흡기 환자 예방 기반 Swift Student Challenge 아이디어 브리프

## 참고 영상

- https://www.youtube.com/watch?v=wk6WIlWPdU0

## Problem Brief: Preventable Breathing Crises in Daily Life

## 1. Decision Context (Owner / Deadline / Why Now)

- Decision: Swift Student Challenge 2026 제출 주제를 `호흡기 환자의 예방 행동 + 위기 시 소통` 문제로 확정할지 결정
- Owner: Hyeongik Kim
- Decision Deadline: 2026년 2월 20일
- Why Now: SSC 제출 마감일(2026년 2월 28일) 전 최소 1주일의 구현/테스트 시간이 필요함

## 2. Problem Summary (Current vs Desired Gap)

- Current: 호흡기 환자와 보호자는 예방 수칙을 알고 있어도 일상에서 꾸준히 실천하기 어렵고, 위기 순간에는 소통 비용이 급격히 증가함
- Desired: 일상 예방 행동이 작고 반복 가능한 루틴으로 정착되고, 위기 순간에도 최소한의 입력으로 도움 요청 및 대응 정보 공유가 가능해야 함

## 3. Target Users and Stakeholders

- Primary User: COPD 등 만성 호흡기 질환 환자
- Secondary User: 가족 보호자
- Stakeholders: 재활/호흡기 의료진(교육 콘텐츠 자문), SSC 심사위원(사회적 임팩트/포용성 관점)

## 4. Evidence and Confidence (Fact + Source + Confidence)

- Fact 1: CDC는 호흡기 바이러스 예방을 위해 최신 백신 접종, 실내 공기 개선, 손 위생 등을 권고함
- Source: CDC Respiratory Illnesses Prevention (2024-06-11)
- Confidence: High

- Fact 2: CDC는 혼잡한 실내, 환기 부족 공간, 본인/주변 고위험군이 있는 상황에서 마스크 착용을 권고함
- Source: CDC About Masks (2024-04-18)
- Confidence: High

- Fact 3: NHLBI는 COPD 예방/관리에서 금연, 간접흡연 회피, 오염원 회피를 제시함
- Source: NHLBI COPD Prevention (접근일: 2026-02-16)
- Confidence: High

- Fact 4: NHLBI는 COPD 환자에게 백신(독감, COVID-19, RSV, 폐렴구균 등)과 폐 재활, 운동 훈련을 제시함
- Source: NHLBI Living With COPD (접근일: 2026-02-16)
- Confidence: High

- Fact 5: WHO는 COPD 위험요인으로 흡연/간접흡연, 대기오염, 직업성 먼지/연기 등을 제시함
- Source: WHO COPD Fact Sheet (2024-06-16)
- Confidence: High

## 5. Assumptions

- 사용자는 긴 교육보다 1~2분짜리 짧은 예방 루틴을 더 꾸준히 수행할 것이다
- 보호자는 위기 시 텍스트보다 시각적 신호/버튼 기반 인터페이스에 더 빠르게 반응할 것이다
- 예방 행동의 완료 체크는 환자에게 통제감과 자기효능감을 제공할 것이다

## 6. Unknowns / Open Questions

- 한국의 실제 호흡기 환자/보호자에게 가장 실행이 어려운 예방 행동은 무엇인가?
- 위기 소통에서 가장 필요한 메시지 포맷(문장/아이콘/색상 코딩)은 무엇인가?
- 1주일 사용에서 이탈의 가장 큰 원인은 알림 피로인지, 조작 복잡도인지?

## 7. Root Cause Hypotheses and Validation Plan

- Hypothesis A: 예방 행동 실패의 핵심 원인은 지식 부족보다 행동 전환 비용이 높기 때문임
- Validation: 환자/보호자 5~8명에게 기존 행동 로그 인터뷰 + 하루 1분 미션 프로토타입 A/B 테스트(3일)

- Hypothesis B: 위기 상황 대응 지연의 핵심 원인은 호흡 곤란 시 고비용 의사소통임
- Validation: 1탭 도움 요청 UI vs 텍스트 입력 UI를 시나리오 테스트로 비교(과제 완료 시간 측정)

## 8. Impact Sizing (User + Business)

- User Impact: 예방 루틴 정착, 위기 불안 감소, 보호자의 대응 자신감 향상
- Project Impact(SSC): 사회적 영향(실사용 문제), 포용성(저호흡 상황 UI), 창의성(상황기반 인터랙션) 강화

## 9. Scope In / Out and Non-goals

- In Scope: 오프라인 동작 가능한 일일 예방 체크 루틴
- In Scope: 위기 시 1탭 소통 카드(예: 도움 필요, 지금 숨이 참)
- In Scope: 예방 행동 실패 시 대체 행동 제안(예: 짧은 실내 루틴)

- Out of Scope: 질병 진단/치료 결정을 자동화하는 기능
- Out of Scope: 실시간 병원 시스템 연동
- Out of Scope: 약물 용량/처방 변경 가이드

- Non-goal: 의료진을 대체하는 의학적 판단 도구를 만드는 것

## 10. Constraints and Dependencies

- SSC 심사 환경 특성상 네트워크 없이 핵심 흐름이 작동해야 함
- 의료 정보 표현은 공신력 가이드 기반으로 제한해야 함(과장/단정 금지)
- 짧은 개발 기간 내 구현 가능한 인터랙션 범위로 축소 필요

## 11. Success Metrics (North Star / Leading / Guardrail)

- North Star: `예방 루틴 5개 항목 중 일일 3개 이상 완료한 비율`
- North Star 목표: Baseline 40% -> Target 70% (2주 파일럿, 인앱 체크 이벤트 기준)

- Leading: `위기 소통 카드 과제 완료 시간` 20초 -> 8초 (사용성 테스트 기준)
- Leading: `일일 앱 재방문율` 1주 평균 45% 이상

- Guardrail: `불안 자기평가 점수(1~5)`가 사용 전 대비 1점 이상 악화되는 사용자 비율 10% 이하

## 12. Risks and Mitigations

- Risk 1: 의료 조언처럼 오해될 수 있음
- Mitigation: 의료 경고 문구 + 응급 시 지역 응급번호 사용 안내 + 비진단성 표현 유지

- Risk 2: 알림 피로로 인한 이탈
- Mitigation: 알림 강도/시간 사용자 설정 + 알림 최소화 모드 제공

- Risk 3: 고령 사용자 조작 어려움
- Mitigation: 큰 터치 타깃, 단순 내비게이션, VoiceOver/Dynamic Type 우선 적용

## 13. Next Discovery Actions

- 2026-02-17: 환자/보호자 인터뷰 질문지 확정
- 2026-02-18: 1차 인터랙티브 프로토타입(루틴 + 위기카드) 제작
- 2026-02-19: 사용성 테스트(5명) 및 핵심 지표 측정
- 2026-02-20: SSC 최종 주제 확정

## 14. Recommendation Snapshot

We should prioritize preventable breathing-crisis support for respiratory patients and caregivers in the 2026 SSC submission window, because evidence from CDC/NHLBI/WHO consistently shows actionable prevention behaviors (vaccination, masks, air quality, smoking avoidance, pulmonary rehab) that are hard to sustain in daily life. Confidence: Medium-High. Decision needed by 2026-02-20 from Hyeongik Kim.

## SSC 제출용 아이디어 3안 (문제 기반)

1. `BreathBridge` (추천)
- 핵심 문제: 예방 행동의 낮은 지속성과 위기 소통 지연
- 핵심 기능: 60초 예방 루틴 카드(백신/손위생/마스크/환기/금연/활동)
- 핵심 기능: 위기 시 1탭 도움 요청 카드 + 보호자에게 보여줄 상태 화면
- 핵심 기능: 주간 리포트(오프라인)로 실천한 예방 행동 시각화
- SSC 강점: 사회적 영향 + 포용성 + 3분 데모 구성이 명확함

2. `Silent Breath SOS`
- 핵심 문제: 호흡 곤란 시 말하기 자체가 어려운 소통 단절
- 핵심 기능: 텍스트 없는 아이콘 기반 의사표현 보드
- 핵심 기능: 상황별 대응 체크리스트(사용자-보호자 공통)
- 핵심 기능: 야간 모드(저자극 UI)와 대형 버튼 인터페이스
- SSC 강점: 접근성 중심 UX 스토리가 강함

3. `Air Habit Quest`
- 핵심 문제: 예방 수칙을 알고도 행동으로 옮기지 못함
- 핵심 기능: 트리거 기반 시나리오 학습(혼잡한 실내/환기 부족/대기오염 상황)
- 핵심 기능: 사용자가 선택한 행동에 따라 위험도 변화 피드백
- 핵심 기능: 짧은 미션 기반 습관 형성 루프
- SSC 강점: 교육적 가치 + 인터랙티브 스토리텔링

## 참고 근거 링크

- CDC Respiratory Illnesses Prevention: https://www.cdc.gov/respiratory-viruses/prevention/index.html
- CDC About Masks: https://www.cdc.gov/respiratory-viruses/prevention/masks.html
- NHLBI COPD Prevention: https://www.nhlbi.nih.gov/health/copd/prevention
- NHLBI Living With COPD: https://www.nhlbi.nih.gov/health/copd/living-with
- WHO COPD Fact Sheet: https://www.who.int/news-room/fact-sheets/detail/chronic-obstructive-pulmonary-disease-(copd)
