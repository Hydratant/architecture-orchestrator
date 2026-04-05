# AGENTS.md

## Purpose

이 문서는 Android / Clean Architecture 프로젝트에서 Codex architecture orchestra를 사용할 때 적용하는 프로젝트 규칙 템플릿이다.

## Custom Agents

- `architect_orchestrator`: 요청 해석, 탐색 위임, 병렬 분석 병합, 구현 전략 결정, 최종 보고를 담당한다.
- `domain_guardian`: domain entity, value object, use case, business rule의 순수성과 책임 경계를 검토한다.
- `data_guardian`: repository, data source, DTO, mapper, cache, sync, error model 구조를 검토한다.
- `presentation_guardian`: UI state, event, side effect, navigation, ViewModel 또는 Presenter 책임을 검토한다.
- `contract_guardian`: DTO, domain model, UI state 사이의 계약 구조와 변환 책임을 검토한다.
- `architecture_reviewer`: 전체 구조를 감사자 관점에서 재검토한다.
- `test_verifier`: 테스트 필요 항목, 검증 명령, 회귀 위험을 점검한다.

## Built-in Agents

- `explorer`: 영향 파일 탐색, 실행 경로 파악, 관련 심볼 추적 같은 읽기 중심 탐색에 사용한다.
- `worker`: 실제 코드 수정, 파일 생성, 필요한 리팩터링을 수행하는 주 구현 agent로 사용한다.

## Recommended Flow

1. `architect_orchestrator`가 요청을 해석한다.
2. `explorer`로 관련 파일, 모듈, 실행 흐름을 탐색한다.
3. 필요 시 `domain_guardian`, `data_guardian`, `presentation_guardian`, `contract_guardian`를 병렬 호출한다.
4. `architect_orchestrator`가 분석 결과를 병합하고 구현 전략을 고정한다.
5. 실제 수정은 가능하면 `worker` 하나에게 집중시킨다.
6. 구현 결과를 `architecture_reviewer`가 구조 관점에서 재검토한다.
7. `test_verifier`가 테스트, 빌드, 회귀 위험을 확인한다.
8. `architect_orchestrator`가 최종 결과를 요약한다.

## Architecture Rules

- 모듈 의존 방향의 기준은 반드시 `feature -> domain <- data` 로 유지한다.
- `feature` 모듈은 `domain`에만 의존할 수 있으며 `data`를 직접 참조하면 안 된다.
- `data` 모듈은 `domain`에만 의존할 수 있으며 `feature` 또는 UI/presentation 구현에 의존하면 안 된다.
- `domain` 모듈은 `feature`, `data`, Android framework 구현 세부사항에 의존하면 안 된다.
- domain은 외부 데이터 포맷, UI 포맷, Android framework 세부 타입을 알면 안 된다.
- data는 domain contract를 구현하되, DTO, local entity, remote model을 경계 밖으로 직접 노출하지 않는다.
- feature 또는 presentation 계층은 UI state와 interaction 흐름에 집중하고, persistence 또는 transport 모델에 직접 결합하지 않는다.
- DTO -> Domain -> UI state 변환은 각 경계에서 명시적으로 수행한다.
- nullability, enum, error model 변환은 암묵적으로 넘기지 말고 경계에서 명시한다.
- 레이어 내부 품질과 별개로, 레이어 간 contract 누수는 독립적인 결함으로 취급한다.

## Collaboration Rules

- 여러 agent가 동시에 같은 파일을 수정하지 않는다.
- guardian, reviewer, verifier는 기본적으로 read-heavy 또는 verification-heavy 역할을 유지한다.
- 실제 구현은 가능하면 `worker` 하나로 수렴시킨다.
- `architect_orchestrator`는 결정권자이고 `architecture_reviewer`는 감사자다. 두 역할을 섞지 않는다.
- 불필요한 재위임이나 깊은 subagent 체인을 만들지 않는다.
- 장기적으로 유지할 규칙은 agent 개별 프롬프트보다 이 문서에 우선 기록한다.

## Naming Rules

- custom agent 이름은 문서 기준 명칭을 그대로 사용한다.
- agent 이름만 보고도 책임이 드러나야 한다.
- 새로운 agent를 추가할 때는 기존 책임과 겹치지 않도록 역할을 좁게 정의한다.
- 리뷰 성격 agent의 출력은 항상 문제와 근거 중심으로 작성한다.

## Test And Verification Commands

- 기본 검증 명령은 `./gradlew test`, `./gradlew lint`, `./gradlew assembleDebug`를 우선 사용한다.
- 계측 테스트가 필요한 변경은 `./gradlew connectedDebugAndroidTest`를 검토한다.
- 모듈 범위가 명확하면 전체 빌드보다 영향 모듈 기준의 가장 좁은 Gradle task를 먼저 선택한다.
- 실행하지 못한 테스트나 빌드는 반드시 미실행 이유와 함께 보고한다.

## Prohibited Patterns

- `feature -> data` 직접 의존
- `data -> feature` 또는 `data -> presentation` 의존
- `domain -> feature` 또는 `domain -> data implementation` 의존
- DTO 또는 persistence model을 presentation까지 직접 전달하는 것
- domain이 Android, Retrofit, Room, UI framework 타입에 직접 의존하는 것
- mapper 책임을 여러 레이어에 흩뿌려 변환 위치가 불명확해지는 것
- `architecture_reviewer`가 직접 구현을 주도하는 것
- 여러 writer가 같은 파일을 병렬 수정하는 것
- contract 변경을 문서화하지 않은 채 경계를 우회하는 것
