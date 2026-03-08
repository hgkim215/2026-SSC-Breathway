# PRD: Breathway (Swift Student Challenge 2026)

- 문서 버전: v1.3
- 작성일: 2026-02-19
- 앱명(App Name): `Breathway`
- 문서 목적: Swift Student Challenge 2026 제출용 COPD 사용자 대상 호흡+저강도 운동 습관 형성 앱의 제품 요구사항 정의
- 참고 문서:
- `docs/ssc_breath_core_mvp_strategy.md`
- `docs/swift_student_challenge_analysis.md`

## 0. Platform and Runtime Constraints (Xcode App Playground)

- **대상 플랫폼은 `iPadOS`이며, `iPad`에서 실행되는 서비스이다.**
- **앱은 가로 모드(Landscape) 전용으로 실행된다. 세로 모드(Portrait)는 지원하지 않는다.**
- 제출 형태는 `App Playground(.swiftpm)` ZIP이어야 한다.
- ZIP 용량은 최대 `25MB`를 초과하지 않아야 한다.
- 개발/실행 기준은 `Swift Playground 4.6` 또는 `Xcode 26+`이다.
- 심사는 오프라인 기준이므로, 앱은 네트워크 연결 없이 핵심 흐름 100% 동작해야 한다.
- 앱 리소스(이미지/사운드/카피/데이터)는 ZIP 내부 로컬 번들에 포함해야 한다.
- 출품작은 1인 단독 제작(또는 1인이 템플릿 단독 수정)이어야 하며 공동 작업물은 심사 대상이 아니다.
- 타사 오픈소스 코드, 저작권 없는 이미지/사운드 사용은 허용되며 크레딧과 사용 이유를 함께 제공해야 한다.
- Apple Pencil 통합은 선택 사항이다.
- 제출 콘텐츠는 영어 기준을 따른다.
- 정책 원칙: 위 공식 제출 요구사항을 충족하는 한, 그 외 구현 기술/라이브러리/아키텍처 선택은 팀 재량으로 허용한다.

## 1. Product Overview

`Breathway`는 COPD를 포함한 호흡기 불편 사용자가 매일 2~3분의 짧은 호흡+저강도 움직임을 꾸준히 실천하도록 돕는 오프라인 중심 코칭 앱이다.
본 제품의 핵심 가치는 "위기 대응"이 아니라 "중단하지 않는 재활 습관"이며, 안전 기능은 이를 지지하는 가드레일로 제공한다.
개발 형태는 `Xcode 기반 iPadOS App Playground(.swiftpm)`를 기본 전제로 하며, iPad 가로 모드(Landscape)에서 실행된다.

## 1.1 Founder Motivation (Submission Narrative)

- 본 프로젝트는 창작자의 가족 경험에서 시작되었다.
- 창작자의 아버지는 COPD로 산소호흡기를 사용하며 생활하고, 운동 필요성을 알아도 숨참 때문에 운동 지속이 어렵다.
- 이 서비스의 핵심 목적은 "완벽한 운동"이 아니라 "매일 이어지는 작은 운동"을 통해 근력과 심폐 지구력 저하를 늦추는 것이다.

## 2. Problem Statement

- 현재 상태(Current): COPD 사용자는 운동 필요성을 인지해도 숨참 두려움, 피로, 지루함 때문에 루틴을 며칠 내 중단하기 쉽다.
- 목표 상태(Desired): 사용자가 부담 없는 강도로 매일 1회 이상 짧은 루틴을 완료하고, 호흡운동을 재미 요소와 함께 지속해 근력/심폐 기능 유지 행동을 습관화해야 한다.
- 핵심 갭: "운동 필요성 인지"는 높지만 "재미 있고 지속 가능한 실행 구조"가 부족하다.

## 3. Goals and Non-goals

## 3.1 Product Goals

- 3분 심사 시간 내 핵심 가치(짧고 꾸준한 재활 습관 형성)를 명확히 전달
- 일일 미션 완료율과 7일 재방문율 개선
- COPD 사용자에게 안전한 저강도 움직임 실천 빈도 증가
- 호흡운동을 반복 가능한 경험으로 만드는 미션 변주/보상 구조 제공
- 접근성(VoiceOver, Dynamic Type, 큰 터치 영역) 우선 설계
- Xcode App Playground 제약 내에서 안정적으로 빌드/실행 가능한 기술 범위 유지

## 3.2 Non-goals

- 임상 폐기능 수치 측정(FEV1, SpO2, L/min 등)
- 병원 시스템/웨어러블/외부 센서 실시간 연동
- 약물 용량/처방 변경 등 의료적 의사결정 지원
- 소셜 피드/랭킹 중심 커뮤니티 기능

## 3.3 Differentiation Goal (Not a Generic Breathing App)

- 일반 명상 앱과 달리 "호흡만"이 아니라 "호흡 + 간단 동작"을 1개 루프로 통합한다.
- 일반 운동 앱과 달리 고강도 성과가 아니라 COPD 사용자에게 맞는 "저강도 지속성"을 핵심 성공으로 정의한다.
- 하루 성취를 작게 쪼개 즉시 보상하고, 다음날 재시작 장벽을 낮추는 습관 설계를 제공한다.

## 3.4 Apple Design Awards 2025 Alignment Goal

- Apple Design Awards 2025 수상작 공통점(기쁨/포용/혁신/상호작용/사회적 영향력/비주얼)을 "습관 형성"에 연결한다.
- 제출 빌드에서 심사자가 3분 내 아래 3가지를 즉시 인지해야 한다.
- `Delight`: 호흡과 동작 반복이 지루하지 않게 작은 변주와 성취 피드백 제공
- `Inclusivity`: 접근성 기능이 별도 모드가 아닌 기본 UX에 통합됨
- `Social Impact`: COPD 사용자의 운동 이탈을 줄이는 실질적 루틴 구조가 명확히 작동함

## 4. Success Criteria

- 심사 데모 기준: 3분 30초 내 핵심 루프(체크 -> 호흡 -> 움직임 -> 결과) 완료 가능
- 오프라인 기준: 네트워크 없이 전체 핵심 흐름 100% 동작
- 사용성 기준: 오늘 루틴 시작까지 1탭, 일시정지/재개가 즉시 가능
- 운동 지속성 기준: 주 5일 이상 루틴 실천 여부를 로컬에서 추적 가능
- 재미 지속성 기준: 완료 직후 성취 피드백과 다음 행동 안내가 즉시 확인 가능
- 품질 기준: 주요 크래시 0건, 데모 차단 버그 0건

## 4.1 Single-Cycle Time Budget (Submission Build)

- Readiness Check: 8~12초
- Breathing Play: 60초 (Submission 기본 고정)
- Light Movement: 90초 (`일어서기 3초 + 앉기 3초` x 15랩)
- Cooldown + Result: 20~30초
- 화면 전환 버퍼: 10~15초
- 일반 경로 목표: 약 3분 05초~3분 35초
- 안전 경로(중단/회복 스크립트 포함) 목표: 약 4분 05초 이내

## 5. Target Users and Stakeholders

## 5.1 Primary User

- 운동 지속이 어려운 COPD 환자 및 만성 호흡기 불편 사용자

## 5.2 Secondary User

- 보호자/가족(사용자의 루틴 지속을 지지하는 역할)

## 5.3 Stakeholders

- 제품 오너: Hyeongik Kim
- 멘토/리뷰어: Academy 멘토 및 동료 테스터
- 외부 이해관계자: Swift Student Challenge 심사위원

## 5.4 Social Impact Definition (Why This Matters)

- 핵심 사회문제: COPD 사용자는 "해야 하는 운동"을 "계속할 수 있는 운동"으로 전환하기 어렵다.
- 1차 수혜자: COPD 등 만성 호흡기 불편 사용자(일상 재활 지속성 향상)
- 2차 수혜자: 보호자/가족(중단이 아닌 재시도 패턴을 함께 확인)
- 3차 수혜자: 돌봄 네트워크(장기적 기능 저하 예방 행동의 생활화)
- 가치 가설:
- `Burden -> Tiny Action`: 운동 부담을 2~3분 행동으로 축소
- `Boredom -> Play`: 단조로운 호흡 루틴을 미션형 상호작용으로 전환
- `Dropout -> Streak`: 중단 경험보다 연속 실천 경험을 강화
- `Fear -> Safe Retry`: 숨참 순간에도 실패 낙인 없이 안전 재시도 유도

## 5.5 Social Impact Boundaries

- 본 서비스는 질병 치료 효과를 주장하지 않는다.
- 임상적 진단/처방/응급의학 판단을 대체하지 않는다.
- 사회적 임팩트는 "운동 지속성, 재시도율, 주간 실천일수" 관점에서 정의한다.

## 6. Scope Definition

## 6.1 In Scope (Must)

- 60초 호흡 미션 1종
- 90초 저강도 움직임 미션 1종: `Sit-to-Stand`(일어서기 3초 + 앉기 3초, 총 6초 1랩 x 15랩)로 고정
- 하루 1회 루틴 기본 구조: `체크 -> 호흡 -> 움직임 -> 결과`
- 미션 완료 즉시 성취 피드백(문구)
- 주간 캘린더 기반 진행 현황
- One-Thumb Safe Mode(큰 버튼, 일시정지/중단/도움)
- 안전 가드레일(증상 악화 시 즉시 중단 + 회복 가이드)
- 오프라인 동작 + 접근성 적용
- App Playground(`.swiftpm`) 단일 타겟 구조에서 동작하는 경량 아키텍처

## 6.2 In Scope (Should)

- 주간 목표 달성 배지(예: 3일/5일/7일)

## 6.3 Out of Scope

- 의료기기 오해를 유발하는 생체 신호 정확도 주장
- 클라우드 동기화 및 계정 시스템
- 다국어 UI(제출 버전은 영어 고정)
- 이번 제출 범위를 벗어나는 대규모 백엔드 운영 기능

## 6.4 Default Movement Selection Rationale

- 기본 동작은 `Sit-to-Stand`로 고정한다.
- 근거 1: COPD 재활 가이드라인은 유산소+근력(저항) 운동의 결합을 권장한다.
- 근거 2: COPD에서 근력운동은 근력 및 기능 개선에 유의한 이점이 보고되었다.
- 근거 3: `1-minute sit-to-stand`는 COPD에서 기능 상태/재활 반응을 반영하는 실용 지표로 널리 검증되어 있다.
- 추론: 제출 빌드 제약(짧은 세션, 무장비, 실내 실행, 안전성)을 고려할 때 `Sit-to-Stand`가 단일 기본 동작으로 가장 실행 가능성이 높다.

## 7. User Experience and Information Architecture

## 7.1 Core Screens (5 + 1 Optional)

- Home: 오늘 미션 카드 + 시작 CTA + 스트릭 요약
- Readiness Check: 숨참/피로/자신감 상태 입력
- Breathing Play: 리듬 가이드 + `Inhale/Exhale 세기 비주얼라이저` + 미션 피드백 + 안전 버튼
- Move Play: `Sit-to-Stand` 동작 + 호흡 템포 동기화
- Result: 오늘 성취, 다음 행동 1줄, 스트릭 반영
- Progress(선택): 주간 캘린더, 안전 중단 로그

## 7.2 Primary User Flow

1. Home에서 `Start Today's Mission` 탭
2. Readiness Check 수행 후 오늘 루틴 시작
3. Breathing Play 60초 진행(리듬 큐 + 실시간 세기 시각화 + 즉시 피드백)
4. Move Play 90초 진행(`Sit-to-Stand`: 일어서기 3초 + 앉기 3초(6초) x 15랩 + 호흡 템포)
5. Result에서 성취 확인 및 내일 재시작 메시지 확인
6. 필요 시 Progress에서 주간 연속성 확인

## 7.3 Signature Innovation Loop (3-Minute Demo Core)

1. 8~12초 상태 체크로 오늘 컨디션 확인
2. 호흡 미션에서 `현재 세기`와 리듬 안정 구간을 동시에 시각화
3. 움직임 미션에서 호흡 템포를 유지한 채 `Sit-to-Stand` 완료
4. 완료 즉시 "오늘의 Tiny Win" 피드백 제공
5. 완료 결과가 즉시 반영되어 다음 실천 동기를 강화
6. 증상 악화 시 안전 중단 후 회복 가이드로 전환, 루틴 재시도 선택 제공

## 7.4 Creative UI Direction (Creativity Boost)

- 디자인 콘셉트: `Lighthouse Rhythm`
- 아트 스타일: `Soft Painterly` (부드러운 브러시 질감 + 저채도 그라데이션 기반)
- 컨셉 문장: `Your breath lights the way.`
- 시각 은유: 사용자의 호흡이 등대 빛을 안정시키고, 움직임으로 항로 부표를 점등해 "오늘의 항로"를 완성한다.
- 상태별 컬러 시스템:
- Harbor Dawn(Ready): 안개 낀 블루그레이
- Sea Active(Active): 틸/시안
- Beacon Gold(Win): 따뜻한 골드
- Safety Alert: 고대비 레드(안전 이벤트에서만 사용)
- 모션 원칙:
- Inhale: 등대 광륜(halo)이 부드럽게 확장
- Exhale: 등대 빔이 길게 뻗으며 선명도 증가
- 완료 연출은 폭발형 이펙트 대신 "부표가 순차 점등되는 차분한 상승"으로 통일
- 세기 표현 원칙:
- 세기는 숫자 점수 대신 3단계 밴드(`Gentle/Steady/Strong`)와 등대 빔의 형태 변화로 전달
- `Gentle`: 짧고 부드러운 빔, `Steady`: 가장 안정적이고 곧은 빔, `Strong`: 두껍고 에너지가 큰 빔
- Inhale/Exhale 위상 전환 시 빔의 길이/두께/선명도가 자연스럽게 연결되어 "내 숨의 흐름"을 직관적으로 인지하게 함
- `Sit-to-Stand` 구간에서는 90초(6초 x 15랩) 동안 항로 부표가 누적 점등되어 운동 수행이 세계관 진행으로 느껴지게 한다.
- 타이포그래피 원칙:
- 핵심 카피는 짧고 행동 중심(`Keep the light steady`, `Buoy lit`, `Harbor secured for today`)
- 정보 계층은 "행동 버튼 > 현재 진행률 > 설명 텍스트" 순서로 고정
- 아트 가드레일:
- 배경 질감은 시각적 분위기용으로만 사용하고, 기능 정보 레이어(세기 밴드/버튼/상태 텍스트)는 고대비 플레인 레이어로 분리
- 페인터리 질감은 10~15% 강도로 제한하여 정보 가독성을 침범하지 않음

## 7.5 Emotional Storytelling Arc (Session Narrative)

1. Start Small: 부담을 줄이는 진입 문구로 시작
2. Find Rhythm: 호흡과 동작이 맞춰지는 구간을 시각적으로 강화
3. Claim a Win: 완료 즉시 작지만 확실한 성취를 확인
4. Build Momentum: 내일도 가능한 짧은 목표로 종료

### 7.5.1 Narrative Copy Tone

- 금지 톤: 죄책감 유발, 압박형 명령, 의료적 단정
- 권장 톤: 비판 없는 코칭, 짧은 문장, 재시도 친화 메시지
- 예시 카피(영문):
- `Small steps still count.`
- `You kept the rhythm. Great work.`
- `Tomorrow starts from here.`

## 7.6 Hero Moment Spec (Judge Memory Anchor)

- 대표 장면 이름: `The Harbor Lights Up`
- 대표 문장(발표/화면 고정): `When your breath gets steady, the path home lights up.`
- 데모 고정 구간: 01:20~01:40
- 연출 시퀀스:

1. Breathing Play에서 `Steady` 구간 유지 시 등대 빔이 곧고 길게 안정화
2. Move Play 진행 동안 부표가 한 개씩 점등되어 항로가 이어짐
3. 90초 종료 시 항로가 완성되고 오늘 미션 카드가 `Harbor Secured`로 전환
4. Result에서 스트릭 +1과 함께 `You kept the light steady today.` 카피 노출
5. `Ready for tomorrow` CTA가 다음 행동을 명확히 제시

- 연출 목적: 사용자의 호흡/운동이 앱 세계를 실제로 바꾼다는 인과를 명확히 체감시키는 것

## 7.7 ADA 2025 Winner Pattern Translation (Design Requirements)

- 분석 기준 페이지: `https://developer.apple.com/kr/design/awards/` (2025 수상작)
- 제품 반영 원칙:
- `Delight and Fun`: 반복 루프에 작은 변주와 즉시 보상을 넣어 지루함을 줄인다.
- `Inclusivity`: VoiceOver/Dynamic Type/Reduce Motion을 기본 제약으로 설계한다.
- `Innovation`: 복잡한 판단은 내부에서 처리하고 사용자에게는 단순한 다음 행동만 제시한다.
- `Interaction`: 입력과 결과의 인과를 즉시 보여주어 "내가 해냈다" 감각을 강화한다.
- `Social Impact`: 장기적 운동 이탈을 줄이는 구조가 3분 데모에서 명확히 보이도록 한다.
- `Visuals and Graphics`: 상태와 성취 변화가 색/모션/타이포에서 일관되게 표현된다.

## 7.8 Apple-Preferred UX Micro-Standards (Submission)

- 첫 5초에 `Start Today's Mission` CTA 1개를 시각 최우선 배치
- 첫 20초에 "현재 상태 -> 시작" 구조를 이해 가능해야 함
- 완료 직후 3초 내 성취 피드백(카피 + 진행 반영) 제공
- 재시도 유도 카피는 실패 낙인이 아닌 연속성 중심으로 고정

## 8. Functional Requirements

| ID    | 요구사항                                                                              | 우선순위 | 수용 기준                                                                                                 |
| ----- | ------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------- |
| FR-01 | 사용자는 Home에서 1탭으로 오늘 미션을 시작할 수 있어야 한다                           | P0       | 첫 화면 진입 후 30초 내 미션 시작 가능                                                                    |
| FR-02 | Readiness Check에서 숨참/피로/자신감 상태를 입력할 수 있어야 한다                     | P0       | 상태 입력 후 5초 내 다음 단계 이동                                                                        |
| FR-04 | Breathing Play는 60초 타이머 기반 리듬 가이드를 제공해야 한다                         | P0       | 60초 종료 시 완료 이벤트 발생                                                                             |
| FR-05 | Move Play는 90초 `Sit-to-Stand` 가이드를 제공해야 한다                                | P0       | `일어서기 3초 + 앉기 3초`(6초 1랩) 기준으로 15랩 완료 시 미션 종료                                        |
| FR-06 | 사용자는 세션 중 Pause/Resume/Stop를 대형 버튼으로 실행할 수 있어야 한다              | P0       | 한 손 조작으로 각 버튼 탭 가능                                                                            |
| FR-07 | 증상 악화 입력 시 미션은 즉시 중단되어야 한다                                         | P0       | 이벤트 발생 후 1초 내 중단                                                                                |
| FR-08 | 중단 후 Recovery Guide(자세 정렬/긴 날숨/재확인)가 표시되어야 한다                    | P0       | 중단 직후 회복 가이드 화면 진입                                                                           |
| FR-09 | Result에서 완료 여부, 소요 시간, 다음 행동 1줄을 확인할 수 있어야 한다                | P0       | 결과 화면 20초 내 핵심 정보 인지 가능                                                                     |
| FR-10 | Progress에서 최근 7일 완료 상태를 캘린더로 확인할 수 있어야 한다                      | P1       | 7일 완료/미완료 시각 구분                                                                                 |
| FR-11 | 하루 성취가 연속 실천 기록으로 즉시 반영되어야 한다                                   | P0       | Result 진입 후 1초 내 업데이트 반영                                                                       |
| FR-13 | 앱은 네트워크 없이 전체 핵심 흐름을 수행해야 한다                                     | P0       | 비행기 모드에서 핵심 기능 정상 동작                                                                       |
| FR-14 | 모든 핵심 텍스트는 영어로 제공되어야 한다                                             | P0       | 심사 핵심 화면에서 비영어 문구 없음                                                                       |
| FR-15 | VoiceOver 탐색이 핵심 인터랙션에서 가능해야 한다                                      | P0       | Home/Check/Play/Result 라벨 제공                                                                          |
| FR-16 | Dynamic Type 확장 시 주요 콘텐츠가 잘리지 않아야 한다                                 | P0       | 접근성 큰 글꼴에서도 CTA 노출 유지                                                                        |
| FR-17 | 의료 대체 금지 문구를 핵심 플로우에서 확인 가능해야 한다                              | P0       | Home 또는 Result에서 고정 문구 노출                                                                       |
| FR-18 | 세션/진행 데이터는 로컬 JSON 저장소에 저장되어야 한다                                 | P0       | 앱 재실행 후 최근 기록 유지, `UserDefaults/FileManager`에서 복원 가능                                     |
| FR-20 | 사용자는 안전 사유로 움직임 단계를 스킵할 수 있어야 한다                              | P0       | 스킵 시 `Skipped for safety` 로그 기록                                                                    |
| FR-21 | 스킵 후에도 루틴 완료를 "재시도 가능 완료"로 저장해야 한다                            | P1       | 결과에 재시도 안내 문구 노출                                                                              |
| FR-22 | Home은 오늘 미션 카드, 스트릭, 시작 CTA를 한 화면에 제공해야 한다                     | P0       | 5초 시야 테스트에서 CTA 인지율 80% 이상                                                                   |
| FR-23 | 완료 직후 성취 카피는 12단어 이하로 제공되어야 한다                                   | P1       | 카피 규칙 위반 0건                                                                                        |
| FR-24 | 정보 전달은 색상 단독 인코딩을 금지해야 한다                                          | P0       | 모든 상태가 색상+아이콘+텍스트로 표현                                                                     |
| FR-25 | 호흡 큐는 시각 + 햅틱(선택)으로 제공되어야 한다                                       | P1       | 햅틱 Off 시에도 동일 루프 동작                                                                            |
| FR-26 | Reduce Motion 활성 시 대체 모션 스킴을 제공해야 한다                                  | P0       | 비필수 애니메이션 축소 동작 확인                                                                          |
| FR-27 | Switch Control/Voice Control/Full Keyboard Access로 핵심 루프를 수행할 수 있어야 한다 | P0       | 대체 입력으로 시작-완료 가능                                                                              |
| FR-28 | Safety 핵심 버튼은 최소 72pt 터치 타깃을 만족해야 한다                                | P0       | Pause/Stop/Help 버튼 72pt 이상                                                                            |
| FR-29 | 핵심 조작 결과는 300ms 이내 시각 반응을 보여야 한다                                   | P1       | Start/Pause/Stop 입력 후 300ms 내 UI 반응                                                                 |
| FR-31 | 제출 빌드는 네트워크 유무와 무관하게 핵심 루프가 중단 없이 동작해야 한다              | P0       | 비행기 모드에서 체크->호흡->움직임->결과 완주 가능                                                        |
| FR-32 | Progress에서 주간 목표 달성률(예: 5일 목표)을 표시해야 한다                           | P1       | 달성률이 퍼센트로 표시                                                                                    |
| FR-33 | 중단 후 재시작까지 2탭 이내로 복귀 가능해야 한다                                      | P0       | Recovery 이후 재시작 경로 2탭 이하                                                                        |
| FR-34 | 세션 종료 후 "내일 다시 시작" CTA를 제공해야 한다                                     | P1       | Result에 고정 CTA 노출                                                                                    |
| FR-35 | 안전 이벤트는 로컬 로그로 남겨 추후 패턴 확인이 가능해야 한다                         | P1       | 날짜/이벤트 유형 저장 확인                                                                                |
| FR-36 | 심사 데모 모드에서 핵심 루프 3분 30초 내 완주가 가능해야 한다                         | P0       | 체크->호흡->움직임->결과가 3분 30초 내 완료                                                               |
| FR-37 | Move Play 시작 전 `Sit-to-Stand` 안전 자세 안내를 제공해야 한다                       | P0       | 의자 고정/팔걸이 사용 허용/어지러우면 중단 안내 1화면 제공                                                |
| FR-38 | Breathing Play는 현재 `Inhale/Exhale` 세기를 실시간으로 시각화해야 한다               | P0       | 미션 중 200ms 이내 주기로 시각 피드백이 갱신되고, 세기 밴드(`Gentle/Steady/Strong`)가 표시됨              |
| FR-39 | 세기 시각화는 사용자의 목표 구간 유지에 대한 재미 요소를 제공해야 한다                | P1       | `Steady` 밴드를 3초 이상 유지하면 등대 빔 안정 애니메이션과 `Keep the light steady` 카피가 1회 노출됨     |
| FR-40 | 마이크 사용 불가 시 세기 시각화는 안전하게 폴백되어야 한다                            | P0       | 권한 거부/실패 시 `Rhythm-only mode`로 전환되고 핵심 루프는 중단되지 않음                                 |
| FR-41 | Move Play 진행은 `Lighthouse Rhythm` 세계관의 항로 진행으로 시각화되어야 한다         | P1       | Move Play 중 최소 3개 이상의 부표 점등 변화가 순차적으로 나타나고, 종료 시 `Harbor Secured` 상태가 표시됨 |
| FR-42 | 출품 패키지는 App Playground(.swiftpm) ZIP 형태여야 한다                              | P0       | 제출 산출물이 `.swiftpm`을 포함한 ZIP 1개로 구성됨                                                        |
| FR-43 | 출품 패키지 용량은 25MB 이하여야 한다                                                 | P0       | 최종 ZIP 파일 크기 `<= 25MB`                                                                              |
| FR-44 | 앱은 Swift Playground 4.6 또는 Xcode 26+에서 빌드/실행 가능해야 한다                  | P0       | 두 환경 중 하나에서 실행 성공                                                                             |
| FR-45 | 앱 리소스는 모두 로컬로 포함되어 오프라인 심사가 가능해야 한다                        | P0       | 네트워크 차단 상태에서 리소스 누락 없이 핵심 UX 재현                                                      |
| FR-46 | 외부 코드/에셋 사용 시 크레딧과 사용 이유를 제출물에 포함해야 한다                    | P0       | `docs/CREDITS.md`에 라이선스/출처/사용 사유 기재 완료                                                     |
| FR-47 | 출품작은 단독 제작물이어야 하며 협업 산출물은 포함하지 않아야 한다                    | P0       | 제출 체크리스트에 1인 제작 확인 항목 포함                                                                 |

## 9. Non-functional Requirements

- 성능: 핵심 화면 전환 지연 체감 1초 이내
- 신뢰성: 데모 플로우 중 크래시 0회
- 접근성: VoiceOver, Dynamic Type, 일반 56pt / Safety 72pt 터치 타깃
- 오프라인: 네트워크 의존 API 없음
- 보안/개인정보: 민감 의료정보 수집 금지, 로컬 최소 데이터 저장
- 콘텐츠: 의료효과 단정 금지, 비진단성 표현 유지
- 감정 UX: 과도한 죄책감/실패 연출 금지, 재시도 친화 톤 유지
- 배포형식: Xcode App Playground(.swiftpm)에서 단일 실행 타겟으로 빌드 가능
- 기술 선택: 공식 제출 요구사항을 해치지 않는 범위에서 라이브러리/구현 방식 자유

## 9.1 Apple Design Quality Bar (From 2025 Winners)

- 즉시성: 입력 후 피드백 지연 체감이 없어야 함(목표 300ms 이내)
- 명료성: 화면마다 "지금 해야 할 행동"이 1개로 수렴되어야 함
- 일관성: 상태별 컬러/모션/카피 톤이 세션 내 흔들리지 않아야 함
- 동기부여: 결과 화면이 평가가 아니라 다음 실천을 촉진해야 함
- 공감성: COPD 사용자의 실제 제약(숨참/피로/낮은 자신감)을 반영한 언어 사용

## 9.2 Accessibility Excellence Spec (Extreme Accessibility)

- 입력 접근성:
- Safety 버튼 최소 72pt, 일반 인터랙션 최소 56pt
- 버튼 간 최소 간격 12pt, 오작동 방지를 위한 보호 여백 8pt
- 핵심 액션은 화면 하단 65% 이내에 배치(한 손 조작 기준)
- 시각 접근성:
- 일반 텍스트 대비 4.5:1 이상, 안전 관련 텍스트 7:1 이상
- 색상 외 추가 인코딩(아이콘/텍스트/모양) 의무화
- Dynamic Type 접근성 최대 크기에서 잘림 없이 재배치
- 페인터리 배경 위 핵심 정보는 항상 반투명 솔리드 백플레이트를 사용해 대비 유지
- 인지 접근성:
- 한 화면 1개 핵심 행동 원칙 유지
- 안전 지시 문구는 12단어 이하, CEFR A2~B1 수준 영어 사용
- 자동 사라지는 중요 경고 금지
- 보조기기 접근성:
- VoiceOver 라벨/힌트/Traits 완비
- Switch Control, Voice Control, Full Keyboard Access 전 경로 지원
- 촉각/청각 접근성:
- 소리 기반 안내는 항상 시각/햅틱 대체 수단 제공
- 햅틱 강도 3단계 + Off 제공
- 전정/감각 민감성 대응:
- Reduce Motion에서 파형 변형 축소, 페이드 중심 대체 전환 사용
- 점멸/급가속 연출 금지

## 9.3 App Playground Technical Compliance

- 프로젝트 구조는 App Playground 기본 구조(`Package.swift`, `Sources`, `Resources`)를 유지한다.
- 제출물은 `.swiftpm` ZIP 25MB 이하를 만족해야 한다.
- 앱은 오프라인 심사에서 핵심 루프를 완주할 수 있어야 한다.
- 사용 리소스는 모두 로컬 번들에 포함해야 한다.
- Swift Playground 4.6 또는 Xcode 26+에서 실행 가능해야 한다.
- 외부 코드/에셋 사용 시 `docs/CREDITS.md`에 출처/라이선스/사용 사유를 제공해야 한다.
- 단독 제작 원칙을 만족해야 한다.
- 그 외 기술 선택(프레임워크/아키텍처/내부 도구)은 팀 재량으로 허용한다.

## 10. Data and State Model

## 10.1 Entities

- Session(date, completed, duration, preCheckDyspnea, preCheckFatigue, confidence, breathCompleted, moveCompleted, safetyStop)
- MissionProfile(type, breathDuration, moveDuration, movementKind)
- BreathIntensitySummary(sessionId, avgInhaleEffort, avgExhaleEffort, timeInSteadyBandSec)
- WeeklySummary(weekStartDate, completionDays, streakDays, safetyStops)
- Achievement(badgeId, unlockedAt)

## 10.2 Storage

- `Codable + UserDefaults/FileManager(JSON)` 기반 로컬 저장 사용
- 네트워크 동기화 없음

## 10.3 Fallback Rules

- 마이크 권한 거부/실패 시:
- 리듬 코칭은 타이머/시각/햅틱 기반으로 폴백
- 세기 비주얼라이저는 비활성화하고 `Rhythm-only mode` 배지를 표시
- 저사양/프레임 저하 시:
- 배경 이펙트 축소, 핵심 피드백 우선 렌더링

## 10.4 Breath Effort Visualization Spec

- 목적:
- 의료 수치가 아닌 "내가 지금 얼마나 크게/안정적으로 숨 쉬는지"를 실시간으로 재미 있게 인지하게 함
- 입력:
- `AVAudioRecorder` 미터링(권한 허용 시), 갱신 주기 50ms(20Hz)
- 전처리:
- 입력 dB를 선형 진폭으로 변환: `amp = 10^(dB/20)`
- EMA 스무딩(`alpha = 0.25`)으로 급격한 튐 완화
- 정규화:
- 세션 초기 6초에서 `floor`/`peak_ref` 추정
- `effort = clamp((amp - floor) / max(EPS, (peak_ref - floor)), 0, 1)`
- 밴드 매핑:
- `Gentle`: 0.00~0.32
- `Steady`: 0.33~0.66
- `Strong`: 0.67~1.00
- UI 출력:
- 현재 위상(`Inhale`/`Exhale`) + 현재 밴드 + 연속 유지 시간 표시
- 안정성 규칙:
- 단발성 노이즈로 밴드가 빠르게 점멸하지 않도록 300ms 히스테리시스 적용
- 주의:
- 본 지표는 의료적 정확도/진단 목적이 아닌 코칭용 시각 피드백이다.

## 11. Safety and Compliance Requirements

- 고정 문구: `This app does not provide medical diagnosis or treatment.`
- 위험 신호(가슴 통증, 심한 어지러움 등) 입력 시 즉시 중단
- 중단 후 회복 가이드: 멈춤 -> 자세 정렬 -> 긴 날숨 -> 상태 재확인
- 응급 상황 시 지역 응급번호 연락 안내 제공

## 12. Analytics and Metrics

## 12.1 North Star Metric

- `Weekly Active Rehab Days (WARD)`: 주간 기준 5일 이상 루틴을 완료한 사용자 비율
- 초기 목표(2주 파일럿 가정): 30% -> 55%

## 12.2 Leading Metrics

- 미션 시작률(Home 노출 대비)
- 세션 완료율(시작 대비 결과 도달)
- 호흡 단계 완료율
- 호흡 `Steady` 밴드 유지 시간(초)
- 호흡 세기 시각화 노출 대비 유지 성공률
- 움직임 단계 완료율
- 주간 실천일수(0~7일)
- 7일 재방문율
- 스트릭 3일 도달률
- 스트릭 5일 도달률
- 중단 후 재시작 성공률

## 12.3 Guardrail Metrics

- 안전 중단 이벤트 비율
- 사용 후 자가 상태 악화 비율(숨참/피로 입력 기준)
- Day 2 이탈률(첫날 설치 후 다음날 미복귀 비율)

## 12.4 Core Event Taxonomy

- `mission_started`
- `readiness_check_completed`
- `breathing_play_completed`
- `breath_effort_band_changed`
- `breath_effort_steady_streak_achieved`
- `lighthouse_beam_stabilized`
- `harbor_buoy_lit`
- `harbor_secured`
- `move_play_completed`
- `mission_completed`
- `mission_stopped_for_safety`
- `recovery_guide_started`
- `mission_restarted_after_recovery`
- `streak_updated`
- `weekly_goal_progressed`

## 12.5 Submission Baseline Compliance Policy (SSC)

- 제출 필수 조건:
- `.swiftpm` ZIP 형식, 최대 25MB
- 오프라인 심사 완주 가능 + 리소스 로컬 포함
- Swift Playground 4.6 또는 Xcode 26+에서 실행
- 영어 콘텐츠 유지
- 단독 제작 원칙 준수
- 외부 코드/에셋 사용 시 크레딧 및 사용 이유 명시(`docs/CREDITS.md`)
- 구현 자율성:
- 위 필수 조건을 충족하는 한, 내부 기술 스택/아키텍처/계측 방식은 팀 재량으로 결정한다.

## 12.6 Social Impact Indicators (Submission Narrative Ready)

- 사용자 관점:
- "운동을 끊지 않고 이어갈 수 있다"는 경험이 결과 화면에서 반복 확인되는지
- 부담 없는 루틴으로 재시도 장벽이 낮아졌는지
- 보호자 관점:
- 중단 로그와 재시도 패턴을 통해 지지 타이밍을 파악할 수 있는지
- 심사 관점:
- 문제(운동 이탈) -> 기능(짧은 루틴+재미 요소+안전 가드레일) -> 변화(주간 실천일수 증가) 연결이 3분 내 전달되는지

## 13. Milestones and Delivery Plan (2 Weeks)

- Day 1: App Playground 기술 스파이크(`.swiftpm` 구조, 권한 플로우, 오프라인 실행) + IA 확정
- Day 2: Home/Readiness Check 구현
- Day 3: Breathing Play 구현
- Day 4: Move Play 구현
- Day 5: Result/연속 실천 반영 구현 + 로컬 JSON 저장 파이프라인 확정
- Day 6: 로컬 저장 + WeeklySummary 연결
- Day 7: 접근성 1차 점검
- Day 8: Readiness 체크/폴백 안정화
- Day 9: 안전 중단/회복/재시작 플로우 완성
- Day 10: 영문 카피 고정 + 정책 문구 확정
- Day 11: 3분 데모 스크립트/리허설 + 오프라인/로컬리소스/ZIP 크기/영어 콘텐츠 검증
- Day 12: 사용자 테스트 5명(COPD 유사 페르소나)
- Day 13: 피드백 반영 + 안정화
- Day 14: 제출 패키징/최종 점검

## 14. Demo Acceptance Checklist

- 첫 실행 후 30초 내 미션 시작 가능
- 3분 30초 내 핵심 루프(체크 -> 호흡 -> 움직임 -> 결과) 완료 가능
- 호흡 60초 + 움직임 90초 단계가 정상 완료됨
- 완료 직후 연속 실천 반영이 즉시 보임
- 중단 시 Recovery Guide 즉시 전환 및 재시작 경로 2탭 이내 제공
- 네트워크 없이 데모 100% 재현
- 영어 콘텐츠 및 의료 고지 문구 노출 확인
- VoiceOver/Dynamic Type/Color contrast 점검 완료
- 상태 전환(Ready/Active/Win/Safety) 시 모션/카피/컬러가 일관됨
- Reduce Motion + VoiceOver + Switch Control 조합에서도 핵심 루프가 끊기지 않음
- Safety 버튼(72pt)과 색상 외 중복 인코딩이 모든 안전 화면에서 유지됨
- 첫 5초 시야 테스트에서 주 CTA 인지율 80% 이상
- Result 진입 후 3초 내 성취 피드백 문장 노출
- Xcode App Playground(.swiftpm)로 열었을 때 추가 설정 없이 실행 가능
- 비행기 모드에서 리소스 누락 없이 데모 완주 가능
- 최종 제출 ZIP 파일 크기가 25MB 이하임
- Swift Playground 4.6 또는 Xcode 26+에서 실행 확인
- 외부 코드/에셋 사용 시 `docs/CREDITS.md`에 출처/라이선스/사용 사유가 기재됨
- 단독 제작 확인 체크 완료(협업 산출물 미포함)

## 15. Risks and Mitigations

- 리스크: 보상 요소가 유치하거나 피로감을 줄 가능성
- 대응: 과도한 게임화 대신 "작은 성취 확인" 수준으로 제한, 사용자 카피 테스트 반복
- 리스크: 안전보다 성취를 우선시하는 오해 가능성
- 대응: 안전 중단 경로를 항상 최상위로 제공, 고정 안전 문구 유지
- 리스크: 접근성 미흡으로 포용성 점수 하락
- 대응: Day 7/12 접근성 테스트를 게이트로 운영
- 리스크: 마감 직전 안정성 저하
- 대응: Day 13 코드 프리즈 후 크리티컬 버그만 수정

## 16. Open Questions

- `Sit-to-Stand`의 기본 템포를 몇 BPM으로 시작할 것인가?
- `Sit-to-Stand` 수행 시 의자 높이/팔걸이 사용 허용 범위를 어느 수준까지 안내할 것인가?

## 17. SSC Evaluation Mapping

- Innovation: COPD 제약에 맞춘 초단기 호흡+움직임 통합 루프 + 안전 중심 상태 체크
- Creativity: `Lighthouse Rhythm` 세계관 안에서 호흡/운동 입력이 실제 장면 변화를 만드는 성취 연출
- Social Impact: "운동 필요성 인지"와 "실제 지속 실행" 사이 간극을 줄이는 습관 구조
- Inclusivity: One-Thumb Safe Mode, 접근성 우선 UI

## 18. Launch Decision

- 출시(제출) Go 조건:
- P0 요구사항 100% 충족
- 데모 차단 버그 0건
- 오프라인/접근성/영어 콘텐츠 체크리스트 완료

- No-go 조건:
- 안전 중단 플로우 실패
- 3분 내 핵심 가치(지속 가능한 루틴) 전달 실패
- 핵심 화면에서 접근성 오류 다수 발견
