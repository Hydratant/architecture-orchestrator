# AGENTS.md

## Purpose

이 저장소는 여러 컴퓨터에서 공통으로 관리할 수 있는 Codex custom agents 번들이다. 루트 `AGENTS.md`는 이 저장소 자체를 유지보수할 때 적용되는 규칙이며, 실제 Android 프로젝트에 넣을 규칙은 `templates/AGENTS.android-project.md`를 사용한다.

## Repository Rules

- 이 저장소의 핵심 산출물은 `.codex/agents/*.toml`이다.
- agent 이름은 안정적으로 유지한다. 기존 이름 변경은 호환성 영향이 있을 때만 한다.
- root `AGENTS.md`는 이 설정 저장소를 관리하기 위한 문서다. 대상 프로젝트 규칙을 여기에 섞지 않는다.
- 프로젝트별 규칙, 아키텍처 원칙, 테스트 명령은 템플릿 파일로 분리한다.
- 로컬 IDE 설정, 사용자별 상태 파일, 비밀 정보는 저장소에 포함하지 않는다.

## Directory Intent

- `.codex/agents/`: Git으로 관리하는 reusable custom agents
- `templates/`: 다른 프로젝트에 복사하거나 참고할 템플릿
- `docs/`: 설계 배경, 운영 메모, 장문 문서
- `scripts/`: 반복 설치나 동기화를 자동화할 때 사용하는 보조 스크립트

## Editing Rules

- agent별 역할은 좁고 분명하게 유지한다.
- 역할이 겹치면 새 agent를 늘리기보다 기존 agent 책임을 다시 정리한다.
- guardian 계열은 read-heavy, reviewer는 auditor, verifier는 검증 역할을 유지한다.
- orchestrator는 결정과 위임에 집중하고, 구현 책임을 과도하게 가져가지 않는다.
- built-in `explorer`, `worker`와 충돌하는 범용 agent를 만들지 않는다.

## Validation Checklist

- `.codex/agents/` 아래 필요한 TOML이 모두 존재하는지 확인한다.
- 각 TOML에 `name`, `description`, `developer_instructions`가 있는지 확인한다.
- agent 설명과 템플릿 문서가 서로 모순되지 않는지 확인한다.
- 새로운 문서는 "이 저장소 유지보수용"인지 "대상 프로젝트 적용용"인지 구분이 명확해야 한다.

## Prohibited Patterns

- 루트 `AGENTS.md`에 특정 앱 프로젝트의 세부 규칙을 직접 넣는 것
- `.idea`, `.DS_Store`, 로컬 캐시 같은 머신 종속 파일을 저장소에 포함하는 것
- 여러 agent가 사실상 같은 책임을 갖도록 중복 정의하는 것
- 특정 도구 버전이나 개인 경로에 강하게 묶인 지시문을 agent에 하드코딩하는 것
