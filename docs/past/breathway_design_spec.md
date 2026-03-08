# Breathway Design Specification

- 문서 버전: v2.0 (Pen-Synced)
- 업데이트일: 2026-02-23
- 앱명: `Breathway`
- 플랫폼: iPadOS (Landscape 전용)
- Source of Truth: `Breathway.pen`
- 동기화 기준 보드:
  - `Board/V2/01_Foundation` (`AxTM0`)
  - `Board/V2/02_Components` (`9NOCV`)
  - `Board/V2/03_Home` (`TBXpk`)

---

## 1. 문서 목적

이 문서는 **현재 `Breathway.pen`에 구현된 디자인 시스템/컴포넌트/홈 화면**을 기준으로 작성된 실행 스펙이다.
기존 v1.1 문서의 가정 중 `.pen`과 불일치하는 값은 본 문서 기준으로 갱신한다.

---

## 2. 핵심 컨셉

### 2.1 Lighthouse Rhythm

> Your breath lights the way.

- 호흡 안정: 등대 빛의 안정감으로 표현
- 재활 동작(Sit-to-Stand): 항로 진행 메타포로 표현
- 홈 화면은 고요한 새벽 항구 무드(soft painterly)로 진입 장벽을 낮춤

### 2.2 현재 구현 무드

- 주 배경: `./images/background.png` (홈/앱아이콘/파운데이션 무드 모듈 공통)
- 등대 디테일 소스: `./images/lighthouse_mark_source.png`
- 무드 레이어: 따뜻한 안개 오버레이 + 차분한 blue-gray 톤

---

## 3. 구현 범위 (Pen 기준)

### 3.1 구현 완료

- 디자인 토큰 시스템 (`bw2.*`)
- Foundation 보드
- Components 보드 (재사용 컴포넌트 세트)
- Home 화면 단일 템플릿 (`Screen/Home`)

### 3.2 미구현/후속

- `ReadinessCheck`, `BreathingPlay`, `MovePlay`, `Result`, `Progress`, `RecoveryGuide`, `MoveSafetyBriefing`는 본 `.pen`에서 아직 별도 스크린 프레임으로 확정되지 않음
- 다만 해당 흐름을 위한 컴포넌트는 `Board/V2/02_Components`에 일부 준비됨

---

## 4. Theme 축 및 토큰 계약

### 4.1 Theme Axes

- `themeVariant`: `calm_dawn`, `sunset_harbor`, `starlight_bay`
- `surfaceMode`: `light`, `dark`
- `contrastMode`: `normal`, `high`

### 4.2 토큰 네이밍 (현재 기준)

- Prefix: `bw2.`
- Color: `bw2.color.*`
- Type: `bw2.type.*`
- Space: `bw2.space.*`
- Radius: `bw2.radius.*`
- Size: `bw2.size.*`
- Motion: `bw2.motion.*`
- Effects: `bw2.fx.*`

> v1.1에 있던 `$bw.*` 표기는 현재 `.pen` 기준으로 `bw2.*`로 대체됨.

---

## 5. 토큰 상세 (Pen 실측값)

### 5.1 Color

### Core

- `bw2.color.fog.100`: `#D6E1EA`
- `bw2.color.fog.200`: `#AFC3D4`
- `bw2.color.fog.300`: `#93AFC6`
- `bw2.color.fog.400`: `#7897AE`
- `bw2.color.fog.500`: `#5F7F97`
- `bw2.color.deep.700`: `#344E64`
- `bw2.color.deep.800`: `#233A4D`
- `bw2.color.deep.900`: `#142A3D`
- `bw2.color.teal.400`: `#25C8C2`
- `bw2.color.teal.500`: `#1FB7B0`
- `bw2.color.gold.400`: `#E0B84E`
- `bw2.color.gold.500`: `#D6A93D`
- `bw2.color.safety.500`: `#D94B57`
- `bw2.color.surface.board`: `#EEF4F8`
- `bw2.color.text.inverse`: `#F4F9FD`

### Surface/Text (themed)

- `bw2.color.surface.glass`:
  - light/normal `#FFFFFFD9`
  - light/high `#FFFFFFF0`
  - dark/normal `#10233BCC`
  - dark/high `#0B1A2DF0`
- `bw2.color.surface.chip`:
  - light/normal `#6C859B88`
  - light/high `#4F677BCC`
  - dark/normal `#2A3C5199`
  - dark/high `#1D2E4399`
- `bw2.color.text.primary`:
  - light/normal `#0E1A26`
  - light/high `#0A1622`
  - dark/normal `#EAF3FA`
  - dark/high `#FFFFFF`
- `bw2.color.text.secondary`:
  - light/normal `#3E556B`
  - light/high `#233A4D`
  - dark/normal `#BFD0DE`
  - dark/high `#DCEAF5`

### 5.2 Typography

- Primary font: `Inter`
- `bw2.type.display.size`: `56`, weight `700`
- `bw2.type.title.size`: `36`, weight `700`
- `bw2.type.section.size`: `24`, weight `600`
- `bw2.type.body.size`: `18`, weight `400`
- `bw2.type.caption.size`: `14`, weight `400`
- `bw2.type.button.size`: `18`, weight `600`

### 5.3 Spacing / Radius / Size

- Space: `4, 8, 12, 16, 20, 24, 32`
- Radius:
  - `bw2.radius.sm = 12`
  - `bw2.radius.md = 20`
  - `bw2.radius.lg = 28`
  - `bw2.radius.pill = 999`
- Size:
  - `bw2.size.button.min = 56`
  - `bw2.size.safety.min = 72`
  - `bw2.size.content.max = 1200`
  - `bw2.size.heroCta.h = 108`

### 5.4 Motion

- `bw2.motion.fast = 300ms`
- `bw2.motion.medium = 500ms`
- `bw2.motion.slow = 2000ms`

---

## 6. 보드 구성

### 6.1 `Board/V2/01_Foundation` (`AxTM0`)

포함:

- Mood Module (`Foundation/MoodModule`)
  - `Mood/Preview` (`S9KdN`): 홈과 동일한 painterly lighthouse 배경 소스
- Palette, Typography, Spacing/Radius, Touch/Safety 규칙 시각화
- 메시지:
  - `Primary actions should stay within lower 65% zone.`
  - `Always pair safety intent with icon + text + contrast color.`

### 6.2 `Board/V2/02_Components` (`9NOCV`)

- 재사용 컴포넌트 카탈로그 + 상태 갤러리
- 상태 갤러리 라벨: `Default`, `Pressed`, `Disabled`, `Active`, `Safety`, `Success`

### 6.3 `Board/V2/03_Home` (`TBXpk`)

- 타이틀: `Breathway Home Screen`
- 실제 홈 프레임: `Screen/Home` (`Uj36D`), `1194x834`

---

## 7. 컴포넌트 계약 (현재 Reusable IDs)

### Brand / Header

- `BW2/Brand/Mark/LighthouseSea` (`iqrSd`) - 56x56, **파동 링 제거된 클린 로고마크**
- `BW2/Brand/Logo` (`s2Gtq`)
- `BW2/Brand/Logo/Breath` (`bv2V1`)
- `BW2/Brand/TopNav` (`icVGf`) - 1240x84
- `BW2/Chip/StreakDate` (`29S5k`) - height 66
- `BW2/Brand/AppIcon` (`0xDlg`) - 132x132

### Home 핵심 블록

- `BW2/Card/MissionHero` (`AaakE`) - 2600x390 (원본), 홈 인스턴스는 `980x220`로 오버라이드
- `BW2/Metric/LevelXP` (`1G8mv`)
- `BW2/CTA/StartMission` (`5vBzc`)
- `BW2/Tracker/WeekCapsule` (`mGOxU`)
- `BW2/Text/Disclaimer` (`oO8mn`)

### Play / Result / Safety (컴포넌트 준비됨)

- `BW2/Stepper/Session3` (`biLo3`)
- `BW2/Card/Readiness` (`kBX0W`)
- `BW2/Panel/BreathVisual` (`9ZzJX`)
- `BW2/Panel/RouteVisual` (`SKego`)
- `BW2/Card/ResultSummary` (`MuPib`)
- `BW2/Alert/Safety` (`AucBV`)
- `BW2/Actions/SafetyBar` (`zGt3Q`)
- `BW2/Notes/SpecPanel` (`yMvTC`)

---

## 8. `03_Home` 실측 스펙 (`Screen/Home`, `Uj36D`)

### 8.1 캔버스

- 크기: `1194 x 834`
- 코너: `26`
- 프레임 fill: `#E6EDF2`
- 배경 구성:
  - `bgImage` (`2mMS5`): `./images/background.png`
  - `bgOverlay` (`2yh2t`): warm/cool linear overlay
  - `fogLeft` (`RG4aV`): 620x420, x=-90, y=180
  - `fogRight` (`yuaEP`): 520x420, x=760, y=90

### 8.2 레이아웃 앵커 (절대 좌표)

- Header `Home/Header` (`9gBt3`): x=24, y=20, w=1146, h=72
- Mission card instance `mission` (`dZ4da`): x=107, y=307, w=980, h=220
- Week strip `week` (`u5JPj`): x=370, y=661, w=454, h=92
- Disclaimer `disclaimer` (`Hu1Gw`): x=286, y=772, w=622, h=36

### 8.3 Header 상세

- 좌측 브랜드 그룹 (`uT0Kt`):
  - `logoMark` 56x56 (`iqrSd` ref)
  - `Breathway` 34/700
  - bell icon 20
- 우측 streak chip (`TBddj`):
  - `🔥 3-Day Streak`
  - `Feb 19`
  - 높이 72 (홈에서 폰트 22로 오버라이드)

### 8.4 Mission 카드 상세

텍스트/값:

- `TODAY'S MISSION`
- `Breathe 60s + Move 45s`
- `Level 1`
- `+50 XP`
- progress: `240/500 XP`
- tier text: `Standard Level`
- CTA: `Start Today's Mission`

스타일:

- glass panel + border + shadow
- card radius: `bw2.radius.lg`
- CTA gradient: `teal.500 -> teal.400`
- CTA 높이: 110 (56pt min 규칙 충족)

### 8.5 Week Capsule 상세

- 라벨: `Mon ... Sun`
- 오늘 강조: `Thu` (gold text + 28pt marker)
- 나머지 day dot: teal 18
- today dot: gold 28 + stroke

### 8.6 Disclaimer (항상 노출)

- `This app does not provide medical diagnosis or treatment.`
- `Please stop if you feel dizzy or unwell.`
- 홈 인스턴스 폰트: 13

---

## 9. Accessibility & Safety 규칙 (현재 디자인시스템 반영)

- 일반 버튼 최소: `56pt` (`bw2.size.button.min`)
- Safety 버튼 최소: `72pt` (`bw2.size.safety.min`)
- 핵심 액션 하단 65% 영역 배치 원칙 유지
- 상태 표시는 색상 단독 인코딩 금지 (아이콘/텍스트 병행)
- 면책 문구 항상 노출 (Home 기준 구현됨)

---

## 10. Spec Notes 표준 필드

`BW2/Notes/SpecPanel` 기준 고정 필드:

- Motion: `300ms / 500ms / 2s`
- Sound: `start, band shift, buoy lit, safety stop`
- Haptics: `light / medium / heavy`
- Reduce Motion fallback: `static gradient + fade transitions`
- Accessibility equivalence: `visual + icon + text`

---

## 11. v1.1 대비 주요 변경점

- 토큰 prefix: `$bw.*` -> `bw2.*`
- 폰트 기준: SF Pro 중심 서술 -> 실제 구현 `Inter`
- 홈 화면: 추상 와이어 -> `03_Home` 실측/카피/좌표 기반 스펙으로 갱신
- 브랜드 마크: 파동 링 버전 -> 클린 lighthouse mark 버전
- `TopNav`: `logoMark` 기반 구조로 정리
- 디자인시스템에 `BW2/Brand/AppIcon` 신규 추가
- 문서 범위 정리: 현재 `.pen`에 없는 스크린은 “후속 구현”으로 명시

---

## 12. 구현 체크리스트 (Pen 동기화)

- [x] `Board/V2/01_Foundation` 무드 모듈이 홈 배경/등대 무드와 일치
- [x] `Board/V2/02_Components` 재사용 컴포넌트 계약 정리
- [x] `Board/V2/03_Home` 실측 기반 스펙 반영
- [x] `TopNav`가 `logoMark` 사용
- [x] 로고마크 파동 제거 버전 반영
- [x] 앱아이콘 컴포넌트 추가

