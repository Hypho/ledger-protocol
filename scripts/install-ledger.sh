#!/usr/bin/env bash
# Install Ledger files into a target project.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/install-ledger.sh --target <path> [--mode auto|all|claude] [--force]

Modes:
  auto     Select mode from existing project files; defaults to all
  all      Install CLAUDE.md, .claude, and .ledger
  claude   Install CLAUDE.md, .claude, and .ledger

Examples:
  scripts/install-ledger.sh --target ../my-project
  scripts/install-ledger.sh --target ../my-project --mode all --force

On Windows, prefer scripts/install-ledger.ps1 or pass a POSIX path such as /mnt/c/path.
EOF
}

MODE="auto"
TARGET=""
FORCE="0"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

[ -n "$TARGET" ] || {
  echo "Missing --target" >&2
  usage
  exit 2
}

case "$MODE" in
  auto|all|claude) ;;
  *)
    echo "Invalid --mode: $MODE" >&2
    usage
    exit 2
    ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

normalize_target() {
  local input="$1"
  case "$input" in
  [A-Za-z]:\\*|[A-Za-z]:/*)
    if command -v cygpath >/dev/null 2>&1; then
      cygpath -u "$input"
      return
    fi
    if command -v wslpath >/dev/null 2>&1; then
      wslpath -u "$input"
      return
    fi
    echo "Windows path requires cygpath or wslpath: $input" >&2
    exit 1
    ;;
  [A-Za-z]:*)
    echo "Unsupported Windows path in bash: $input" >&2
    echo "Use a POSIX path such as /mnt/c/path, or run scripts/install-ledger.ps1 from PowerShell." >&2
    exit 1
    ;;
  esac
  printf '%s\n' "$input"
}

TARGET_NORM="$(normalize_target "$TARGET")"
TARGET_ABS="$(mkdir -p "$TARGET_NORM" && cd "$TARGET_NORM" && pwd)"

detect_mode() {
  if [ -e "$TARGET_ABS/.claude" ] || [ -e "$TARGET_ABS/CLAUDE.md" ]; then
    echo "claude"
  else
    echo "all"
  fi
}

REQUESTED_MODE="$MODE"
if [ "$MODE" = "auto" ]; then
  MODE="$(detect_mode)"
fi

copy_item() {
  local src="$1"
  local dst="$2"
  local dst_path="$TARGET_ABS/$dst"

  [ -e "$ROOT/$src" ] || {
    echo "Missing source: $src" >&2
    exit 1
  }

  if [ -e "$dst_path" ] && [ "$FORCE" != "1" ]; then
    echo "Refusing to overwrite existing path: $dst"
    echo "Use --force to overwrite."
    exit 1
  fi

  if [ -e "$dst_path" ]; then
    rm -rf "$dst_path"
  fi

  mkdir -p "$(dirname "$dst_path")"
  cp -R "$ROOT/$src" "$dst_path"
}

install_claude() {
  copy_item "CLAUDE.md" "CLAUDE.md"
  copy_item ".claude" ".claude"
  copy_item ".ledger" ".ledger"
  copy_item "skills" "skills"
  copy_item "hooks" "hooks"
  copy_item ".claude-plugin" ".claude-plugin"
}

case "$MODE" in
  all)
    copy_item "CLAUDE.md" "CLAUDE.md"
    copy_item ".claude" ".claude"
    copy_item ".claude-plugin" ".claude-plugin"
    copy_item ".ledger" ".ledger"
    copy_item "skills" "skills"
    copy_item "hooks" "hooks"
    ;;
  claude) install_claude ;;
esac

cat <<EOF
Ledger installed.

Target: $TARGET_ABS
Mode:   $MODE
EOF

if [ "$REQUESTED_MODE" = "auto" ]; then
  echo "Auto:   selected from existing project files"
fi

cat <<EOF

Next:
- Claude Code: run /ledger.init, then /ledger.scope before the first feature.
- Self-check:
    cd "$TARGET_ABS"
    bash .ledger/bin/ledger.sh check --project
EOF

case "$(uname -s 2>/dev/null || true)" in
  MINGW*|MSYS*|CYGWIN*)
    cat <<'EOF'

Windows note:
- If you are in PowerShell, run scripts/install-ledger.ps1 instead.
- If you are in Git Bash, keep using POSIX-style paths for bash commands.
EOF
    ;;
esac
