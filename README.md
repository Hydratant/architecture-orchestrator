# Android Architecture Orchestrator

Reusable Codex custom agents bundle for Android / Clean Architecture analysis workflows.

## What This Repo Is

이 저장소는 실제 앱 코드 저장소가 아니라, Codex custom agents와 관련 문서를 GitHub로 동기화하기 위한 설정 저장소다. 여러 컴퓨터에서 동일한 agent 구성을 유지하고, 필요할 때 각 프로젝트로 복사하거나 연결해서 사용하기 위한 목적이다.

## Should This Repo Keep `AGENTS.md`?

예. 다만 역할을 분리해서 써야 한다.

- 루트 `AGENTS.md`는 이 저장소 자체를 관리할 때 Codex가 읽는 유지보수 규칙이다.
- 실제 Android 프로젝트에 넣을 프로젝트용 규칙은 `templates/AGENTS.android-project.md`를 사용한다.

즉, 이 저장소의 `AGENTS.md`는 필요하지만, 대상 프로젝트 규칙과 같은 문서로 섞으면 안 된다.

## Repository Layout

```text
.
├── .codex/
│   └── agents/
│       ├── architect_orchestrator.toml
│       ├── architecture_reviewer.toml
│       ├── contract_guardian.toml
│       ├── data_guardian.toml
│       ├── domain_guardian.toml
│       ├── presentation_guardian.toml
│       └── test_verifier.toml
├── docs/
│   └── codex_architecture_orchestra_plan.md
├── scripts/
│   └── install-into-project.sh
├── templates/
│   └── AGENTS.android-project.md
├── .gitignore
├── AGENTS.md
└── README.md
```

## How To Use On Another Computer

1. 이 저장소를 clone 한다.
2. agent 정의를 수정하거나 추가할 때는 이 저장소에서 관리한다.
3. 실제 작업할 Android 프로젝트에는 아래 둘 중 하나를 적용한다.

### Option 1: Copy

```bash
cp -R /path/to/android-architecture-orchestrator/.codex /path/to/target-project/
cp /path/to/android-architecture-orchestrator/templates/AGENTS.android-project.md /path/to/target-project/AGENTS.md
```

### Option 2: Symlink

```bash
ln -s /path/to/android-architecture-orchestrator/.codex /path/to/target-project/.codex
ln -s /path/to/android-architecture-orchestrator/templates/AGENTS.android-project.md /path/to/target-project/AGENTS.md
```

Copy는 프로젝트별로 독립적으로 조정할 때 유리하고, symlink는 여러 프로젝트가 같은 설정 원본을 공유할 때 유리하다.

### Option 3: Use the helper script

```bash
bash scripts/install-into-project.sh /path/to/target-project --link
```

또는:

```bash
bash scripts/install-into-project.sh /path/to/target-project --copy
```

스크립트는 대상 프로젝트에 기존 `.codex` 또는 `AGENTS.md`가 이미 있으면 덮어쓰지 않고 중단한다.

## Recommended Usage

대상 프로젝트에서 Codex를 시작한 뒤, 메인 프롬프트에서 `architect_orchestrator`를 진입점으로 쓰는 방식을 권장한다.

Example:

```text
Use architect_orchestrator for this task.

1. First use explorer to find the relevant files.
2. Spawn domain_guardian, data_guardian, presentation_guardian, and contract_guardian in parallel.
3. Merge the findings and choose one implementation strategy.
4. Delegate code changes to worker only.
5. Run architecture_reviewer.
6. Run test_verifier.
7. Summarize changes, risks, and follow-up work.
```

## Notes

- 이 저장소의 루트에서 Codex를 실행하면, 루트 `AGENTS.md`는 "설정 저장소 유지보수" 규칙으로 읽힌다.
- 실제 앱 저장소에서 Codex를 실행할 때만 프로젝트용 `AGENTS.md`가 적용된다.
- 따라서 프로젝트용 규칙은 반드시 대상 프로젝트 루트에 있어야 한다.
