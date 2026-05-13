#!/bin/bash
# Check whether a /ledger.* command is allowed to start.
# This script has no side effects: it does not execute commands or modify files.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LEDGER_ROOT="${LEDGER_ROOT:-$ROOT}"
cd "$LEDGER_ROOT"

fail() {
  echo "❌ $1"
  exit 1
}

pass() {
  echo "✅ $1"
}

run_check() {
  local label="$1"
  shift
  local output
  if ! output="$("$@" 2>&1)"; then
    fail "${label}
${output}"
  fi
}

STATE_FILE="${LEDGER_STATE_FILE:-$LEDGER_ROOT/.ledger/state.md}"

normalize_state() {
  sed -e 's/：/:/g' -e 's/\*\*//g' "$STATE_FILE"
}

require_state() {
  [ -f "$STATE_FILE" ] || fail "state.md 不存在：$STATE_FILE"
}

extract_feature() {
  normalize_state | awk '
    /功能[[:space:]]*:/ {
      sub(/^.*功能[[:space:]]*:[[:space:]]*/, "")
      sub(/[[:space:]]*\|.*$/, "")
      sub(/[[:space:]]+$/, "")
      print
      exit
    }
  '
}

extract_phase() {
  normalize_state | awk '
    /阶段[[:space:]]*:/ {
      sub(/^.*阶段[[:space:]]*:[[:space:]]*/, "")
      if (match($0, /待开始|[A-Za-z-]+/)) {
        print substr($0, RSTART, RLENGTH)
      }
      exit
    }
  '
}

extract_blocked() {
  normalize_state | awk '
    /阻塞[[:space:]]*:/ {
      sub(/^.*阻塞[[:space:]]*:[[:space:]]*/, "")
      sub(/[[:space:]]+$/, "")
      print
      exit
    }
  '
}

lint_state_shape() {
  local norm
  norm="$(normalize_state)"
  for field in "功能" "阶段" "开始时间" "正在做" "阻塞"; do
    echo "$norm" | grep -q "${field}[[:space:]]*:" || fail "state.md 缺少字段：${field}"
  done
}

load_state() {
  require_state
  lint_state_shape
  FEATURE="$(extract_feature)"
  PHASE="$(extract_phase)"
  BLOCKED="$(extract_blocked)"

  [ -n "$FEATURE" ] || fail "无法解析当前功能"
  [ -n "$PHASE" ] || fail "无法解析当前阶段"

  case "$PHASE" in
    "待开始"|"pid"|"contract"|"build"|"build-complete"|"verify-pass"|"verify-fail"|"shipped") ;;
    *) fail "非法阶段：$PHASE" ;;
  esac
}

is_idle_feature() {
  [ "$FEATURE" = "[名称]" ] || [ "$FEATURE" = "" ]
}

is_unblocked() {
  [ -z "$BLOCKED" ] || [ "$BLOCKED" = "无" ] || [[ "$BLOCKED" == \[* ]]
}

feature_slug() {
  echo "$FEATURE"
}

guard_pid() {
  load_state
  is_unblocked || fail "/ledger.pid blocked: 当前阻塞字段不是无"
  if is_idle_feature || [ "$PHASE" = "待开始" ] || [ "$PHASE" = "shipped" ]; then
    pass "/ledger.pid allowed: no active feature"
    return
  fi
  fail "/ledger.pid blocked: active feature $FEATURE is in $PHASE phase"
}

guard_contract() {
  load_state
  [ "$PHASE" = "pid" ] || fail "/ledger.contract blocked: 当前阶段是 $PHASE，不是 pid"
  local pid
  pid=".ledger/specs/$(feature_slug)-pid.md"
  [ -f "$pid" ] || fail "/ledger.contract blocked: PID Card 不存在：$pid"
  run_check "/ledger.contract blocked: PID Card lint failed：$pid" bash "$ROOT/.ledger/bin/ledger-lint-pid.sh" "$pid"
  pass "/ledger.contract allowed: PID Card exists"
}

guard_build() {
  load_state
  [ "$PHASE" = "contract" ] || [ "$PHASE" = "verify-fail" ] || fail "/ledger.build blocked: 当前阶段是 $PHASE，不是 contract 或 verify-fail"
  local contract
  contract=".ledger/contracts/$(feature_slug).md"
  [ -f "$contract" ] || fail "/ledger.build blocked: contract 不存在：$contract"
  run_check "/ledger.build blocked: contract lint failed：$contract" bash "$ROOT/.ledger/bin/ledger-lint-contract.sh" "$contract"
  pass "/ledger.build allowed: contract exists and lint passed"
}

guard_verify() {
  load_state
  [ "$PHASE" = "build-complete" ] || fail "/ledger.verify blocked: 当前阶段是 $PHASE，不是 build-complete"
  local contract
  contract=".ledger/contracts/$(feature_slug).md"
  [ -f "$contract" ] || fail "/ledger.verify blocked: contract 不存在：$contract"
  run_check "/ledger.verify blocked: contract lint failed：$contract" bash "$ROOT/.ledger/bin/ledger-lint-contract.sh" "$contract"
  pass "/ledger.verify allowed: build is complete and contract lint passed"
}

guard_ship() {
  load_state
  [ "$PHASE" = "verify-pass" ] || fail "/ledger.ship blocked: 当前阶段是 $PHASE，不是 verify-pass"
  local verify
  verify=".ledger/knowledge/$(feature_slug)-verify.md"
  [ -f "$verify" ] || fail "/ledger.ship blocked: verify 记录不存在：$verify"
  run_check "/ledger.ship blocked: verify lint failed：$verify" bash "$ROOT/.ledger/bin/ledger-lint-verify.sh" "$verify"
  if grep -q '^verdict = PASS$' "$verify" || grep -q 'MANUAL OVERRIDE' "$verify"; then
    pass "/ledger.ship allowed: verify record passed"
    return
  fi
  fail "/ledger.ship blocked: verify 记录缺少 PASS 或 MANUAL OVERRIDE"
}

write_state() {
  local root="$1"
  local feature="$2"
  local phase="$3"
  mkdir -p "$root/.ledger"
  cat > "$root/.ledger/state.md" <<EOF
# Ledger State

## 当前

\`\`\`
功能：$feature | 阶段：$phase
开始时间：2026-04-27 10:00
正在做：guard fixture
阻塞：无
\`\`\`

## 队列

- [ ] [下一个功能]
EOF
}

expect_success() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -eq 0 ] || fail "guard fixture 应通过但失败：$label"
}

expect_failure() {
  local label="$1"
  shift
  set +e
  "$@" >/dev/null 2>&1
  local code=$?
  set -e
  [ "$code" -ne 0 ] || fail "guard fixture 应失败但通过：$label"
}

run_fixtures() {
  GUARD_TMP="$(mktemp -d)"
  trap 'rm -rf "$GUARD_TMP"' EXIT

  mkdir -p "$GUARD_TMP/idle"
  write_state "$GUARD_TMP/idle" "[名称]" "待开始"
  expect_success "pid idle" env LEDGER_ROOT="$GUARD_TMP/idle" bash "$ROOT/.ledger/bin/ledger-guard.sh" pid

  mkdir -p "$GUARD_TMP/contract-missing/.ledger/specs"
  write_state "$GUARD_TMP/contract-missing" "guard-login" "pid"
  expect_failure "contract missing pid" env LEDGER_ROOT="$GUARD_TMP/contract-missing" bash "$ROOT/.ledger/bin/ledger-guard.sh" contract

  mkdir -p "$GUARD_TMP/contract-ok/.ledger/specs"
  write_state "$GUARD_TMP/contract-ok" "guard-login" "pid"
  cp "$ROOT/.ledger/tests/fixtures/pid/valid-pid.md" "$GUARD_TMP/contract-ok/.ledger/specs/guard-login-pid.md"
  expect_success "contract ok" env LEDGER_ROOT="$GUARD_TMP/contract-ok" bash "$ROOT/.ledger/bin/ledger-guard.sh" contract

  mkdir -p "$GUARD_TMP/contract-invalid-pid/.ledger/specs"
  write_state "$GUARD_TMP/contract-invalid-pid" "guard-login" "pid"
  cp "$ROOT/.ledger/tests/fixtures/pid/missing-flow-mapping.md" "$GUARD_TMP/contract-invalid-pid/.ledger/specs/guard-login-pid.md"
  expect_failure "contract invalid pid" env LEDGER_ROOT="$GUARD_TMP/contract-invalid-pid" bash "$ROOT/.ledger/bin/ledger-guard.sh" contract

  mkdir -p "$GUARD_TMP/build-ok/.ledger/contracts"
  write_state "$GUARD_TMP/build-ok" "guard-login" "contract"
  cp "$ROOT/.ledger/tests/fixtures/contract/valid-contract.md" "$GUARD_TMP/build-ok/.ledger/contracts/guard-login.md"
  expect_success "build ok" env LEDGER_ROOT="$GUARD_TMP/build-ok" bash "$ROOT/.ledger/bin/ledger-guard.sh" build

  mkdir -p "$GUARD_TMP/build-invalid/.ledger/contracts"
  write_state "$GUARD_TMP/build-invalid" "guard-login" "contract"
  cp "$ROOT/.ledger/tests/fixtures/contract/missing-fc.md" "$GUARD_TMP/build-invalid/.ledger/contracts/guard-login.md"
  expect_failure "build invalid contract" env LEDGER_ROOT="$GUARD_TMP/build-invalid" bash "$ROOT/.ledger/bin/ledger-guard.sh" build

  mkdir -p "$GUARD_TMP/verify-ok/.ledger/contracts"
  write_state "$GUARD_TMP/verify-ok" "guard-login" "build-complete"
  cp "$ROOT/.ledger/tests/fixtures/contract/valid-contract.md" "$GUARD_TMP/verify-ok/.ledger/contracts/guard-login.md"
  expect_success "verify ok" env LEDGER_ROOT="$GUARD_TMP/verify-ok" bash "$ROOT/.ledger/bin/ledger-guard.sh" verify

  mkdir -p "$GUARD_TMP/ship-ok/.ledger/knowledge"
  write_state "$GUARD_TMP/ship-ok" "guard-login" "verify-pass"
  cp "$ROOT/.ledger/tests/fixtures/verify/valid-pass.md" "$GUARD_TMP/ship-ok/.ledger/knowledge/guard-login-verify.md"
  expect_success "ship ok" env LEDGER_ROOT="$GUARD_TMP/ship-ok" bash "$ROOT/.ledger/bin/ledger-guard.sh" ship

  mkdir -p "$GUARD_TMP/ship-missing/.ledger/knowledge"
  write_state "$GUARD_TMP/ship-missing" "guard-login" "verify-pass"
  cp "$ROOT/.ledger/tests/fixtures/verify/missing-verdict.md" "$GUARD_TMP/ship-missing/.ledger/knowledge/guard-login-verify.md"
  expect_failure "ship missing verdict" env LEDGER_ROOT="$GUARD_TMP/ship-missing" bash "$ROOT/.ledger/bin/ledger-guard.sh" ship

  pass "guard fixtures passed"
}

case "${1:-}" in
  pid) guard_pid ;;
  contract) guard_contract ;;
  build) guard_build ;;
  verify) guard_verify ;;
  ship) guard_ship ;;
  --fixtures) run_fixtures ;;
  *)
    echo "Usage: bash .ledger/bin/ledger-guard.sh <pid|contract|build|verify|ship|--fixtures>"
    exit 2
    ;;
esac
