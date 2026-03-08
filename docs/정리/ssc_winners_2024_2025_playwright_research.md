# Swift Student Challenge 2024~2025 수상작 분석 (Playwright 리서치)

작성일: 2026-02-17  
리서치 방식: `$playwright`로 Apple 공식 페이지(Developer + Newsroom) 직접 탐색

## 1. 조사 범위

- 연도: `2024`, `2025`
- 기준 소스:
  - 2024 수상자 인터뷰 기사 (May 1, 2024)
  - 2025 수상자 인터뷰 기사 (May 8, 2025)
  - SSC `Distinguished Winners` 페이지(2024/2025 사례 포함)
- 참고:
  - 기사 특성상 모든 수상작(350개)을 다루지 않고, 대표 수상자 사례 중심으로 소개됨

## 2. 2024 수상작 사례 분석

## A) Care Capsule (Elena Galluzzo)

- 아이디어/문제:
  - 고령층(특히 치매 환자 포함)의 돌봄/정서 지원 문제를 가족 경험에서 출발해 해결
- 구현 포인트:
  - 복약 관리
  - 커뮤니티 리소스 연결
  - 긍정 기억 기록
- 사용 기술:
  - `Create ML` 기반 챗봇(사용자 상호작용 분석으로 외로움/우울감 징후 추정)

## B) MTB XTREME (Dezmond Blair)

- 아이디어/문제:
  - 산악자전거 경험을 디지털로 몰입감 있게 재현
- 구현 포인트:
  - iPad에서 트레일 `360도 시점` 체험
- 사용 기술:
  - `Swift`
  - (확장 방향) `Apple Vision Pro`용 더 몰입형 버전 계획

## C) My Child (Jawaher Shaman)

- 아이디어/문제:
  - 말더듬(언어장애) 아동/청소년의 발화 훈련 지원
- 구현 포인트:
  - 호흡 조절/읽기 상황 대비 연습
  - 창작자 개인 경험 기반 스토리텔링
- 사용 기술:
  - `AVFAudio`로 문장을 작은 단위로 끊어 들려주는 음성/사운드 가이드 구현

## 3. 2025 수상작 사례 분석

## A) Hanafuda Tactics (Taiki Hamamoto)

- 아이디어/문제:
  - 세대 단절로 사라질 수 있는 전통 카드 게임(Hanafuda) 보존/확산
- 구현 포인트:
  - 초심자용 규칙 학습
  - 전통 룰 + 현대 게임 메커닉(HP) 결합
- 사용 기술:
  - `SwiftUI DragGesture`로 카드 tilt/glow 등 반응형 인터랙션 구현
  - (실험) `Apple Vision Pro` 플레이 가능성 탐색

## B) EvacuMate (Marina Lee)

- 아이디어/문제:
  - 재난 대피 시 고령층/비숙련 사용자의 정보 혼란과 준비 부족
- 구현 포인트:
  - 대피 체크리스트
  - 중요 문서 보관
  - 비상 연락망 구성
- 사용 기술:
  - `iPhone Photos(카메라롤)` 연동
  - `iPhone Contacts` 연동
  - (기사 맥락상) 접근성/다국어 확장 지향

## C) BreakDownCosmic (Luciana Ortiz Nolasco)

- 아이디어/문제:
  - 천문학 커뮤니티 접근성 부족(정보/커뮤니티 진입장벽)
- 구현 포인트:
  - 천문 이벤트 캘린더 등록
  - 미션/메달 기반 참여 유도
  - 사용자 간 채팅
- 사용 기술:
  - `Swift`, `Xcode` 중심 구현

## D) AccessEd (Nahom Worku)

- 아이디어/문제:
  - 교육 자원 접근성 불균형 + 불안정한 인터넷 환경
- 구현 포인트:
  - 온라인/오프라인 학습 리소스 접근
  - 개인화 추천
  - 노트 사진 기반 플래시카드 생성
  - 학습 태스크 관리/알림
- 사용 기술:
  - `Core ML`
  - `Natural Language`
  - `Notifications`(태스크 관리 맥락)

## 4. Distinguished Winners 페이지 기반 보강 사례

아래는 공식 `Distinguished Winners` 페이지에서 확인한 2024~2025 관련 대표 사례다.

- `Fast Aid` (Gaurav Kukreja): 응급상황 단계별 안내 + hands-free 내레이터
- `Yume’s Spellbook` (Larissa Okabayashi): LLM 원리 학습용 AI 리터러시 앱
- `CryptOh` (AJ Nettles): 비밀번호 강도 인식 개선
- `PuzzlePix` (Keitaro Kawahara): 개인 사진으로 퍼즐 자동 생성
- `Deep Blue Tangram` (Ruoshan Li): 아동 대상 바다 테마 퍼즐 + `AR` 활용
- `MyCycle` (Vildan Kocabas): 생리 주기 추적 + 건강 교육

## 5. 2024~2025 공통 패턴 분석

## 1) 아이디어 출발점: 개인 경험 -> 사회 문제

- 가족 돌봄, 재난 대피, 교육 격차, 문화 보존처럼 `개인 경험`에서 출발해 `사회적 확장성`을 확보한 사례가 많음.

## 2) 기술 선택: "최신"보다 "문제-적합성"

- ML이 필요한 곳에만 `Create ML/Core ML/Natural Language`를 사용.
- 단순 정보 앱이어도 `Photos/Contacts/알림` 같은 디바이스 네이티브 기능 결합으로 실사용성을 강화.

## 3) 인터랙션 품질이 평가 포인트

- `SwiftUI` 기반 제스처/시각 반응(예: DragGesture)과 오디오 가이드(AVFAudio)처럼 사용자가 즉시 체감 가능한 상호작용을 강조.

## 4) 접근성/포용성 지향

- 고령층, 언어장애, 저연결 환경 등 특정 제약 조건을 앱 설계 중심에 둠.
- 단순 기능 나열보다 "누가 실제로 더 쉽게 쓸 수 있나"가 명확한 작품이 두드러짐.

## 5) 확장 로드맵 제시

- App Playground 단계에서도 App Store 출시, Vision Pro 확장, 다국어 지원 등 `다음 단계`를 구체적으로 언급한 사례가 반복됨.

## 6. 2024~2025 기준으로 본 기술 트렌드 요약

- 빈도 높음:
  - `Swift`, `SwiftUI`, `Xcode`
  - `Core ML / Create ML / Natural Language`
  - `AVFAudio`
- 확장 축:
  - `Apple Vision Pro`/spatial computing 관심 증가
- 제품 완성도 축:
  - 디바이스 기능 연동(사진/연락처/알림) + 문제 맥락 중심 UX

## 7. 문서 해석 시 유의점

- 기사에 명시되지 않은 프레임워크는 추정하지 않음.
- 일부 기술은 인터뷰에서 "현재 사용"과 "향후 계획"이 혼재하므로 구분해 읽어야 함.

## 8. 참고 링크 (조사 원문)

- SSC Overview  
  https://developer.apple.com/swift-student-challenge/

- SSC Distinguished Winners  
  https://developer.apple.com/swift-student-challenge/distinguished-winners/

- 2025 수상자 기사 (May 8, 2025)  
  https://www.apple.com/newsroom/2025/05/meet-four-of-this-years-swift-student-challenge-winners/

- 2024 수상자 기사 (May 1, 2024)  
  https://www.apple.com/newsroom/2024/05/meet-three-swift-student-challenge-winners-changing-the-future-through-coding/

- (보강 참고) 개발 여정 후속 기사 (Nov 6, 2025)  
  https://www.apple.com/newsroom/2025/11/developers-decode-their-journeys-from-app-ideas-to-app-store/
