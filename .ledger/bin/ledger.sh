#!/usr/bin/env bash
# Unified Ledger command wrapper.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

usage() {
  cat <<'EOF'
Usage: bash .ledger/bin/ledger.sh <command> [args]

Commands:
  check [--repo|--project]          Run Ledger checks
  state <validate|set-phase|enqueue|complete|fail-verify>
                                    Validate or update Ledger state
  guard <pid|contract|build|verify|ship>
                                    Check whether a Ledger stage may start
  lint-contract <file|--all|--fixtures>
                                    Lint behavior contracts
  lint-verify <file|--all|--fixtures>
                                    Lint verify records
  lint-pad <file|--all|--fixtures>  Lint Product Spine / PAD files
  lint-architecture <file|--all|--fixtures>
                                    Lint Architecture Spine files
  lint-pid <file|--all|--fixtures>  Lint PID Cards
  lint-design <file|--all|--fixtures>
                                    Lint optional design attachments
  release-check                     Run optional git-aware release check
  help                              Show this help

Examples:
  bash .ledger/bin/ledger.sh check --project
  bash .ledger/bin/ledger.sh state validate
  bash .ledger/bin/ledger.sh guard build
  bash .ledger/bin/ledger.sh lint-contract --all
EOF
}

cmd="${1:-help}"
if [ "$#" -gt 0 ]; then
  shift
fi

case "$cmd" in
  check)
    bash "$ROOT/.ledger/bin/ledger-check.sh" "$@"
    ;;
  state)
    bash "$ROOT/.ledger/bin/ledger-state.sh" "$@"
    ;;
  guard)
    bash "$ROOT/.ledger/bin/ledger-guard.sh" "$@"
    ;;
  lint-contract)
    bash "$ROOT/.ledger/bin/ledger-lint-contract.sh" "$@"
    ;;
  lint-verify)
    bash "$ROOT/.ledger/bin/ledger-lint-verify.sh" "$@"
    ;;
  lint-pad)
    bash "$ROOT/.ledger/bin/ledger-lint-pad.sh" "$@"
    ;;
  lint-architecture)
    bash "$ROOT/.ledger/bin/ledger-lint-architecture.sh" "$@"
    ;;
  lint-pid)
    bash "$ROOT/.ledger/bin/ledger-lint-pid.sh" "$@"
    ;;
  lint-design)
    bash "$ROOT/.ledger/bin/ledger-lint-design.sh" "$@"
    ;;
  release-check)
    bash "$ROOT/.ledger/bin/ledger-release-check.sh" "$@"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    echo "Unknown Ledger command: $cmd" >&2
    usage
    exit 2
    ;;
esac
