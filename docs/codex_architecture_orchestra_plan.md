# Codex 아키텍처 오케스트라 설계 플랜

## 목적

이 문서는 Codex subagent 기반으로 사용할 **아키텍처 오케스트라** 설계안을 정리한 문서다.
목표는 다음과 같다.

- 레이어별 전문성을 분리하여 분석 품질을 높인다.
- 병렬 분석 후 단일 구현 흐름으로 충돌을 줄인다.
- 최종적으로 아키텍처 규칙, 계약 경계, 테스트 누락 여부까지 검증한다.
- 이 문서를 바탕으로 Codex에게 직접 구현을 요청할 수 있는 프롬프트의 베이스로 사용한다.

---

## 핵심 설계 방향

Codex 오케스트라는 아래 원칙으로 설계한다.

1. **탐색과 검토는 병렬화한다.**
2. **실제 코드 수정은 가능한 한 단일 agent가 담당한다.**
3. **최상위 agent는 결정과 위임, 결과 병합에 집중한다.**
4. **레이어 내부뿐 아니라 레이어 간 경계(contract)도 별도로 검토한다.**
5. **테스트 검증 agent를 마지막 게이트로 둔다.**

즉, 구조는 아래 흐름을 따른다.

**탐색 → 병렬 분석 → 구현 결정 → 단일 구현 → 최종 리뷰 → 테스트 검증**

---

## 권장 Agent 구성

### 1. architect_orchestrator
최상위 agent.

#### 역할
- 사용자 요청을 해석한다.
- 작업을 어떤 subagent에게 위임할지 결정한다.
- 병렬 분석 결과를 수집하고 충돌을 정리한다.
- 최종 구현 전략을 선택한다.
- 최종 결과와 의사결정을 요약한다.

#### 주의점
- 직접 코드를 많이 수정하는 역할보다는 **계획, 위임, 병합, 최종 결정**에 집중한다.
- 하위 agent의 역할이 겹치지 않도록 분배한다.

---

### 2. domain_guardian
Domain Layer 전담 분석 agent.

#### 역할
- 엔티티, 값 객체, 유스케이스, 도메인 규칙의 책임을 검토한다.
- 비즈니스 로직이 다른 레이어로 새고 있지 않은지 확인한다.
- 도메인 모델이 UI나 외부 데이터 포맷에 오염되지 않았는지 검토한다.

#### 집중 포인트
- 순수성
- 유스케이스 책임 범위
- 도메인 모델 표현 방식
- 비즈니스 규칙 응집도

---

### 3. data_guardian
Data Layer 전담 분석 agent.

#### 역할
- Repository 구현 구조를 검토한다.
- Remote / Local data source 분리를 점검한다.
- DTO, Entity, Mapper 구조를 검토한다.
- 캐시, 동기화, 오류 처리 방식의 일관성을 확인한다.

#### 집중 포인트
- 저장소 책임 분리
- Mapper 위치와 책임
- 데이터 소스 추상화
- 에러 모델과 fallback 흐름

---

### 4. presentation_guardian
Presenter / Presentation Layer 전담 분석 agent.

#### 역할
- 화면 상태 관리 구조를 검토한다.
- 이벤트 처리, side effect, navigation 흐름을 점검한다.
- ViewModel / Presenter 책임을 검토한다.
- UI state 표현이 과도하게 data/domain에 의존하지 않는지 확인한다.

#### 집중 포인트
- UI state 설계
- 단방향 데이터 흐름
- side effect 처리
- navigation 책임 위치

---

### 5. contract_guardian
레이어 간 경계 전담 agent.

#### 역할
- DTO ↔ Domain ↔ UI State 사이의 계약 구조를 검토한다.
- 각 레이어가 서로의 내부 구현에 과도하게 의존하지 않는지 확인한다.
- mapper와 contract 변환이 적절한 위치에 있는지 점검한다.

#### 집중 포인트
- DTO가 domain/presentation으로 직접 새는지 여부
- Domain model이 presentation 포맷을 아는지 여부
- nullability, enum, error model 일관성
- backward compatibility 위험 요소

#### 비고
이 agent는 레이어 내부보다 **레이어 간 경계 문제**를 잡기 위해 꼭 필요하다.

---

### 6. architecture_reviewer
전반적인 아키텍처 리뷰 agent.

#### 역할
- 각 guardian이 놓친 전체 구조 문제를 다시 검토한다.
- 레이어 침범, 의존 방향 위반, 책임 중복을 점검한다.
- 제안된 구현 방식이 현재 프로젝트 구조와 맞는지 평가한다.

#### 주의점
- 최상위 orchestrator와 달리 **결정을 내리는 역할이 아니라 검증하는 역할**이다.
- auditor 성격으로 동작해야 한다.

---

### 7. test_verifier
테스트 및 검증 전담 agent.

#### 역할
- 변경 사항에 필요한 테스트를 식별한다.
- 누락된 테스트를 지적한다.
- 가능한 경우 테스트/빌드를 실행한다.
- 회귀 위험을 요약한다.

#### 집중 포인트
- unit test 필요 여부
- integration test 필요 여부
- UI test 필요 여부
- 경계 케이스 누락 여부
- 변경으로 인한 회귀 가능성

---

## Built-in Agent 활용 방안

Custom agent만으로 모든 역할을 해결하려 하지 않는다.

### explorer
읽기 중심 탐색 역할.

#### 용도
- 영향 파일 탐색
- 실행 경로 파악
- 관련 모듈 찾기
- 심볼 참조 추적

### worker
실제 구현 담당 역할.

#### 용도
- 코드 수정
- 파일 생성
- 설정 반영
- 필요한 리팩터링 수행

---

## 추천 오케스트레이션 흐름

### 1단계. 초기 분석
- `architect_orchestrator`가 요청을 해석한다.
- `explorer`에게 관련 파일, 모듈, 흐름을 탐색하게 한다.

### 2단계. 병렬 아키텍처 분석
다음 agent를 병렬로 호출한다.
- `domain_guardian`
- `data_guardian`
- `presentation_guardian`
- `contract_guardian`

### 3단계. 분석 결과 병합
- `architect_orchestrator`가 충돌하거나 겹치는 의견을 정리한다.
- 구현 우선순위와 방향을 선택한다.

### 4단계. 구현
- `worker`가 실제 코드 수정과 파일 생성을 수행한다.
- 가능하면 동시에 여러 writer를 두지 않는다.

### 5단계. 최종 구조 검토
- `architecture_reviewer`가 구현 결과를 다시 검토한다.

### 6단계. 검증
- `test_verifier`가 테스트, 빌드, 회귀 위험을 검토한다.

### 7단계. 최종 보고
- `architect_orchestrator`가 최종 결과를 요약한다.
- 변경 파일, 의사결정, 남은 리스크, 후속 작업을 정리한다.

---

## 왜 이 구조가 좋은가

### 1. 레이어별 전문성과 경계 검증을 동시에 가져갈 수 있다
단순히 domain/data/presentation 전문가만 두면 각 레이어 내부는 잘 보지만, 레이어 사이 contract 문제를 놓치기 쉽다.
그래서 `contract_guardian`을 별도로 둔다.

### 2. 충돌을 줄일 수 있다
분석은 병렬로 수행하되, 실제 구현은 주로 `worker` 하나가 담당하므로 파일 충돌과 조율 비용이 줄어든다.

### 3. 최상위 agent 역할이 명확하다
최상위 agent는 모든 걸 직접 하지 않고, **위임과 결정과 병합**에 집중한다.

### 4. 테스트가 마지막에 빠지지 않는다
구조 검토만 하고 끝나지 않도록 `test_verifier`를 명시적으로 둔다.

---

## 변경/보완 권장 사항

현재 처음 생각한 아래 구성은 방향은 좋다.

- domain Layer 전문가
- data Layer 전문가
- presenter Layer 전문가
- 전반적으로 아키텍처를 검토하는 리뷰어
- 결정을 내리는 최상위 Agent

하지만 실제 운영용 구조로는 아래 보완이 필요하다.

### 추가해야 하는 Agent
1. `contract_guardian`
2. `test_verifier`

### 역할을 더 명확히 나눠야 하는 부분
- **최상위 Agent**: 결정권자
- **아키텍처 리뷰어**: 감사자 / 검증자

즉 둘 다 전체를 본다고 해서 같은 역할로 두면 안 되고,
하나는 **판단**, 하나는 **검증**을 맡도록 분리해야 한다.

---

## 운영 원칙

### 1. 여러 agent가 동시에 같은 파일을 수정하지 않는다
병렬 수정은 충돌 비용이 커진다.
실제 수정은 `worker` 중심으로 모은다.

### 2. guardian 계열은 기본적으로 read-heavy 역할로 둔다
이 agent들은 구조 분석과 제안에 집중한다.
필요한 경우에만 구현까지 위임한다.

### 3. 지속 규칙은 프롬프트보다 AGENTS.md에 둔다
예를 들면 아래 항목은 `AGENTS.md`에 두는 것이 좋다.
- 아키텍처 원칙
- 레이어 의존 방향
- 테스트 실행 명령
- 네이밍 규칙
- 모듈 구조 규칙
- 금지 패턴

### 4. subagent depth는 보수적으로 운영한다
처음에는 깊이를 낮게 유지하고, 하위 agent가 또 다른 agent를 과도하게 생성하지 않도록 한다.

---

## 권장 파일 구조

Codex에게 아래 구조를 생성하도록 요청하는 방향을 권장한다.

```text
.codex/
  agents/
    architect_orchestrator.toml
    domain_guardian.toml
    data_guardian.toml
    presentation_guardian.toml
    contract_guardian.toml
    architecture_reviewer.toml
    test_verifier.toml
AGENTS.md
```

---

## 각 Agent의 기대 성격

| Agent | 주요 목적 | 기본 성격 |
|---|---|---|
| architect_orchestrator | 위임, 병합, 결정 | coordinator |
| domain_guardian | domain 규칙 검토 | read-heavy guardian |
| data_guardian | data 구조 검토 | read-heavy guardian |
| presentation_guardian | presentation 구조 검토 | read-heavy guardian |
| contract_guardian | 계층 간 contract 검토 | read-heavy guardian |
| architecture_reviewer | 전체 구조 재검증 | auditor |
| test_verifier | 테스트/빌드/회귀 검증 | verifier |
| explorer | 코드베이스 탐색 | built-in explorer |
| worker | 실제 구현 | built-in worker |

---

## Codex 구현 요청용 프롬프트 초안

아래 프롬프트를 베이스로 Codex에게 구현을 요청한다.

```text
현재 저장소에 Codex subagent 기반 아키텍처 오케스트라 구성을 추가하고 싶습니다.

목표:
- 레이어별 아키텍처 분석 agent를 정의한다.
- 최상위 orchestrator가 작업을 분배하고 결과를 병합할 수 있게 한다.
- 실제 구현은 worker 중심으로 수행하고, 최종적으로 architecture_reviewer와 test_verifier가 검증할 수 있게 한다.

생성/수정 요청:
1. `.codex/agents/` 디렉토리를 만들고 아래 agent TOML 파일들을 생성해주세요.
   - architect_orchestrator.toml
   - domain_guardian.toml
   - data_guardian.toml
   - presentation_guardian.toml
   - contract_guardian.toml
   - architecture_reviewer.toml
   - test_verifier.toml

2. 프로젝트 루트에 `AGENTS.md`를 생성해주세요.

3. 각 agent는 아래 역할을 반영해주세요.
   - architect_orchestrator: 요청 해석, 작업 분배, 병합, 최종 결정
   - domain_guardian: domain layer 규칙, 유스케이스, 엔티티 책임 검토
   - data_guardian: repository, data source, mapper, cache, error model 검토
   - presentation_guardian: UI state, event, side effect, navigation, presenter/viewmodel 책임 검토
   - contract_guardian: DTO ↔ Domain ↔ UI State 경계와 mapper contract 검토
   - architecture_reviewer: 전체 구조, 의존 방향, 레이어 침범, 책임 중복 검토
   - test_verifier: 테스트 필요 항목, 누락 테스트, 회귀 위험, 실행 가능한 빌드/테스트 검토

4. 설계 원칙:
   - guardian/reviewer 계열은 기본적으로 분석 및 검토 중심으로 설계해주세요.
   - 여러 agent가 동시에 같은 파일을 수정하는 구조는 피해주세요.
   - 실제 수정은 worker가 담당하는 흐름을 전제로 해주세요.
   - 지속적으로 유지되어야 하는 규칙은 AGENTS.md에 정리해주세요.
   - AGENTS.md에는 아키텍처 원칙, 레이어 의존 방향, 네이밍 규칙, 테스트 명령, 금지 패턴을 포함해주세요.

5. 각 TOML 파일에는 다음을 포함해주세요.
   - name
   - description
   - developer_instructions
   - 필요한 경우 model, model_reasoning_effort, sandbox_mode

6. 모델 설정은 초안 기준으로 아래 원칙을 따라주세요.
   - architect_orchestrator: 상대적으로 강한 추론 모델
   - architecture_reviewer: 상대적으로 강한 추론 모델
   - guardian 및 verifier 계열: 경량 또는 중간 수준 모델
   - explorer / worker built-in agent와 충돌하지 않도록 설계

7. 최종적으로 아래 내용을 함께 보고해주세요.
   - 생성된 파일 목록
   - 각 agent 역할 요약
   - AGENTS.md 핵심 항목 요약
   - 이후 개선하면 좋을 포인트

주의사항:
- 과도하게 범용적인 agent를 만들지 말고 역할이 좁고 분명하게 유지되도록 해주세요.
- 동일하거나 겹치는 책임은 분리해주세요.
- 설명은 실제 개발자가 바로 유지보수할 수 있게 명확하게 작성해주세요.
```

---

## 추가로 고려할 수 있는 확장 Agent

처음에는 필수는 아니지만, 이후 필요하면 아래 agent도 고려할 수 있다.

### 1. api_contract_reviewer
- 서버 응답 스키마
- backward compatibility
- API contract 변경 영향

### 2. performance_reviewer
- 불필요한 렌더링
- 무거운 mapper
- 데이터 로딩 비용
- 병목 지점

### 3. documentation_writer
- 결정 사항을 ADR 또는 문서로 정리
- PR 설명 자동화

처음부터 너무 많이 만들기보다, 현재 추천한 최소 구성으로 시작한 뒤 필요 시 확장하는 것을 권장한다.

---

## 최종 권장안 요약

최종적으로 추천하는 v1 구성은 아래와 같다.

### Custom Agents
- architect_orchestrator
- domain_guardian
- data_guardian
- presentation_guardian
- contract_guardian
- architecture_reviewer
- test_verifier

### Built-in Agents
- explorer
- worker

이 구성을 기반으로 Codex에게 직접 `.codex/agents/*.toml`과 `AGENTS.md` 생성을 요청하는 방식으로 시작한다.
