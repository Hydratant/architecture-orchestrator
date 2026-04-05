#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_CODEX_DIR="$ROOT_DIR/.codex"
SOURCE_AGENTS_TEMPLATE="$ROOT_DIR/templates/AGENTS.android-project.md"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/install-into-project.sh /path/to/target-project --copy
  bash scripts/install-into-project.sh /path/to/target-project --link

Options:
  --copy   Copy .codex and AGENTS.md into the target project
  --link   Create symlinks to .codex and AGENTS.md in the target project
EOF
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

TARGET_DIR="$1"
MODE="$2"
TARGET_CODEX_DIR="$TARGET_DIR/.codex"
TARGET_AGENTS_FILE="$TARGET_DIR/AGENTS.md"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

if [[ -e "$TARGET_CODEX_DIR" ]]; then
  echo "Refusing to continue: $TARGET_CODEX_DIR already exists" >&2
  exit 1
fi

if [[ -e "$TARGET_AGENTS_FILE" ]]; then
  echo "Refusing to continue: $TARGET_AGENTS_FILE already exists" >&2
  exit 1
fi

case "$MODE" in
  --copy)
    cp -R "$SOURCE_CODEX_DIR" "$TARGET_CODEX_DIR"
    cp "$SOURCE_AGENTS_TEMPLATE" "$TARGET_AGENTS_FILE"
    ;;
  --link)
    ln -s "$SOURCE_CODEX_DIR" "$TARGET_CODEX_DIR"
    ln -s "$SOURCE_AGENTS_TEMPLATE" "$TARGET_AGENTS_FILE"
    ;;
  *)
    usage
    exit 1
    ;;
esac

echo "Installed Codex agents into: $TARGET_DIR"
echo "  - $TARGET_CODEX_DIR"
echo "  - $TARGET_AGENTS_FILE"
