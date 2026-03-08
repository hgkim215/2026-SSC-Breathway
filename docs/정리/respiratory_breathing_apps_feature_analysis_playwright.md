# 호흡기 환자 대상 호흡운동 앱 기능 분석 (웹 검색 + Playwright)

작성일: 2026-02-17  
수집 방식: `$playwright`로 웹 검색 후 공식 제품 페이지/앱 스토어 페이지 중심 확인

## 1) 분석 목적

- 호흡기 환자(천식/COPD) 대상 앱들이 실제로 제공하는 기능을 파악
- `호흡운동 중심 서비스` 기획 시 어떤 기능 조합이 현실적인지 도출

## 2) 조사 앱 목록 (8개)

1. myCOPD
2. Breathment
3. Kaia Breathe
4. Propeller
5. Wellinks
6. Hailie
7. Airlyn
8. AsthmaMD

## 3) 앱별 기능 정리

## 1. myCOPD (COPD 특화)

- 핵심 기능:
  - 온라인 폐재활(Pulmonary rehabilitation)
  - 흡입기 사용법 비디오
  - 증상/폐기능/리포트 추적
  - COPD 체크리스트
  - 날씨/오염 예보
  - 자가관리 플랜 + 약물 다이어리
  - 환자-의료진 연동/메시지
- 특징:
  - 환자용 기능과 의료진 대시보드가 함께 설계됨

## 2. Breathment (COPD/천식 디지털 치료)

- 핵심 기능:
  - 디지털 호흡/재활 운동 프로그램
  - AI 기반 동작·호흡 패턴 트래킹(정확도 피드백)
  - 증상/진행도 다이어리(`My Day`, `Progress`, `COPD Diary`)
  - 환자 교육 코스
  - 공기질 정보
  - 영상 기반 치료 세션/전문가 코칭
- 특징:
  - `운동 수행 품질` 피드백과 `원격 치료`를 결합

## 3. Kaia Breathe (디지털 폐재활)

- 핵심 기능:
  - 운동 치료 + 가이드 호흡 기법 + 폐질환 교육 + 1:1 코칭
  - AI/모션 분석 기반 24/7 운동 가이드
  - 증거기반 프로그램(RCT 언급)
- 특징:
  - 기능 범위가 "운동-호흡-교육-코칭"으로 패키지화됨

## 4. Propeller (천식/COPD 연결형 흡입기 플랫폼)

- 핵심 기능:
  - 흡입기에 센서 부착 후 사용량 자동 기록
  - 앱 기반 복약 순응도 리마인더/알림
  - 증상/복약 패턴 인사이트 제공
  - 공기질 예보
  - 약 리필(in-app refill), 분실 흡입기 찾기
  - 의료진 포털/API로 원격 모니터링
- 특징:
  - `호흡운동`보다는 `흡입기 복약순응·악화 예방` 중심

## 5. Wellinks (가상 폐재활 + 원격 모니터링)

- 핵심 기능:
  - 가상 폐재활
  - 1:1 임상 코칭, 24/7 간호 트리아지
  - 연결 기기 기반 활력/폐기능 모니터링(스파이로미터, 산소포화도계 관련 설명)
  - 앱 기반 환자 지원/교육
- 특징:
  - 건강보험/의료기관 연계형 `관리 프로그램` 성격이 강함

## 6. Hailie (스마트 흡입기 연동)

- 핵심 기능:
  - Bluetooth 센서로 흡입기 사용 시점 기록
  - 앱 연동 및 복약 알림
  - 시간 경과별 사용 패턴 확인
  - 의사와 데이터 공유
- 특징:
  - `하드웨어 센서 + 앱` 조합의 대표 사례

## 7. Airlyn (천식 호흡 재훈련 앱)

- 핵심 기능:
  - 천식 대상 호흡기법 훈련
  - 호흡 점수 기반 개선 포인트 제시
  - 챌린지 기반 루틴 형성
  - 진행도 추적
- 특징:
  - 짧은 호흡 훈련과 습관화를 전면에 둔 앱

## 8. AsthmaMD (천식/COPD 자가 기록 중심)

- 핵심 기능:
  - 발작/증상 로그
  - 피크플로우(PFM) 기록
  - 유발요인(trigger), 약물, 노트 관리
  - 액션플랜 디지털화
  - 알림/리마인더
  - 의료진 공유
- 특징:
  - `저마찰 기록`과 `의료진 전달`에 초점

## 4) 공통 기능 패턴 (가장 자주 보이는 것)

1. 호흡운동/폐재활 가이드
- 단순 타이머보다 단계형 세션(운동+호흡+교육) 구성이 많음

2. 증상/활동/복약 기록
- 일지(다이어리) + 주간/월간 리포트 형태가 기본

3. 복약 순응도 기능
- 알림, 복약 이력, 흡입기 사용 추적(센서 연동 포함)

4. 환자 교육 콘텐츠
- 질환 이해, 악화 대처, 생활수칙, 약물 사용법

5. 의료진 연계
- 메시지/데이터 공유/원격 모니터링/코칭

6. 환경 맥락 정보
- 공기질·오염·날씨를 일상 의사결정과 연결

7. 동기화 장치
- 진행도, 챌린지, 루틴/습관 형성 UX

## 5) 기능 묶음(Feature Bundles) 관점

## A. 재활 중심형 (myCOPD, Breathment, Kaia, Wellinks)

- 폐재활 세션
- 교육 모듈
- 원격 코칭
- 추적 리포트

## B. 복약/센서 중심형 (Propeller, Hailie)

- 스마트 흡입기 센서
- 복약 순응도 추적
- 알림/예측/원격 모니터링

## C. 자가관리/행동변화 중심형 (Airlyn, AsthmaMD)

- 호흡 훈련 루틴
- 증상/트리거 기록
- 습관화/리마인더

## 6) 시사점 (호흡운동 서비스 기획에 바로 적용)

1. `호흡운동` 단독보다 `기록 + 교육 + 안전`을 붙인 조합이 보편적이다.
2. COPD/천식 타깃은 `복약`과의 연결(흡입기 사용, 알림)이 매우 중요하다.
3. 환자 가치와 의료진 가치가 동시에 설계된 앱(데이터 공유/리포트)이 많다.
4. 공기질/날씨 같은 외부 맥락 정보가 실사용성을 높인다.
5. 소비자형 앱도 가능하지만, 질환 타깃일수록 `의료적 안전 문구`와 `보수적 가이드`가 필수다.

## 7) SSC 관점 최적 구현안 (권장)

`호흡 세기 측정`은 절대값(의료수치) 대신 `상대강도`로 구현하는 것이 가장 현실적이다.

### 구현 컨셉

- 기능명(가칭): `Exhale Quality Ring`
- 방식:
  - `AVAudioRecorder` 미터링으로 날숨 소리 에너지 추적
  - 날숨 지속시간 + 리듬 안정성(흔들림) 결합
  - 결과를 `Gentle / Steady / Strong`으로 시각화
- 핵심:
  - 임상 측정기가 아니라 `재활 훈련 피드백` 도구로 포지셔닝

### 왜 SSC에 유리한가

1. Innovation
- 기존 기록형 앱과 달리 `호흡 품질을 실시간 시각 인터랙션`으로 제공

2. Creativity
- 점수 대신 링/오라 변화로 감각적 피드백 제공 (UI 임팩트 큼)

3. Social Impact
- 숨참이 잦은 사용자가 “무리하지 않는 강도”를 학습하도록 도움

4. Inclusivity
- 큰 UI + 햅틱 + VoiceOver 라벨로 저시력/저집중 상황 대응 가능

### 기술 설계 (MVP)

1. 개인 캘리브레이션 (첫 실행 45~60초)
- 편한 날숨 기준 2~3회
- 조금 강한 날숨 2~3회
- 개인 기준 범위(min/max) 저장

2. 세션 중 실시간 계산
- 입력값:
  - `exhalePowerNorm` (개인 기준 정규화)
  - `exhaleDuration`
  - `stabilityIndex` (세기 변동성)
- 출력값:
  - 현재 강도 밴드(`Gentle/Steady/Strong`)
  - 품질 링(색/두께/파형 변화)

3. 세션 후 피드백
- `세기` 단독이 아니라 `세기 + 회복속도 + 지속성` 조합으로 결과 제공
- 예: `Steady breathing with faster recovery`

### 데이터 모델 예시 (SwiftData)

- `BreathSample(timestamp, phase, powerNorm, duration, stability)`
- `CalibrationProfile(gentleBaseline, strongBaseline, updatedAt)`
- `SessionResult(intensityBand, recoverySeconds, completed, note)`

### 안전/심사 대응 문구 (필수)

- `This app is not a medical device and does not provide diagnosis.`
- 위험 신호(심한 어지러움/가슴 통증) 선택 시 즉시 중단 플로우
- 임상 수치(L/min, FEV1 등)처럼 보이는 표현은 사용하지 않음

### 3분 데모 적용 방식

1. `Pre-check` (10~15초)
2. 호흡 미션 + 품질 링 실시간 표시 (60~90초)
3. 결과 화면에서 회복 기반 피드백 (20~30초)
4. Progress에서 개인 변화 추이 1개만 강조 (20초)

## 8) 리서치 한계

- 공개 웹페이지/스토어 설명 기반으로 정리했으며, 실제 임상 성능은 별도 검증 필요
- 일부 서비스는 국가/보험/기관 제휴 조건에 따라 기능 접근 범위가 달라질 수 있음

## 9) 참고 링크

- myCOPD  
  https://mymhealth.com/mycopd

- Breathment (COPD Product)  
  https://breathment.com/en/product/

- Kaia Breathe  
  https://kaiahealth.com/solutions/kaiabreathe/

- Propeller (Digital Therapeutics Alliance profile)  
  https://dtxalliance.org/products/propeller/

- Wellinks  
  https://www.wellinks.com/

- Hailie (How it Works)  
  https://www.hailie.com/pages/how-it-works

- Airlyn  
  https://airlyn.io/

- AsthmaMD Features  
  https://asthmamd.org/features/

- (보조 참고) Breathe: Guided Exercise Coach (App Store)  
  https://apps.apple.com/us/app/breathe-guided-exercise-coach/id6754893676
