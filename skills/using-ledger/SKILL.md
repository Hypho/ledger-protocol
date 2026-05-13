---
name: using-ledger
description: Use when a project contains .ledger/ directory. Establishes Ledger protocol awareness: state machine, phase-based skill routing, guard enforcement, and core constraints. Must be active before any feature work.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

# Using Ledger

This project uses Ledger — an auditable AI-assisted development protocol.

Ledger is not a suggestion. It is a protocol with hard constraints. When `.ledger/` exists in a project, you follow Ledger rules for all feature work.

## Core Principle

```
Define behavior before implementation.
Verify behavior before shipping.
```

## Session Startup

When you see this skill, immediately:

1. **Read `.ledger/state.md`** — identify current feature name and phase
2. **Read `.ledger/core/constitution.md`** — load project hard constraints
3. **Determine next action** based on current phase (see Phase Routing below)

Do NOT skip reading state.md. Do NOT assume the phase. Read it.

## Phase Routing

Based on the phase in state.md, load the corresponding skill:

| Phase | Condition | Skill to Load | Guard Command |
|-------|-----------|---------------|---------------|
| `待开始` / idle | User requests new feature | `ledger:ledger-pid` | `bash .ledger/bin/ledger.sh guard pid` |
| `pid` | PID Card exists | `ledger:ledger-contract` | `bash .ledger/bin/ledger.sh guard contract` |
| `contract` | Contract exists and lints | `ledger:ledger-build` | `bash .ledger/bin/ledger.sh guard build` |
| `build-complete` | Build done | `ledger:ledger-verify` | `bash .ledger/bin/ledger.sh guard verify` |
| `verify-pass` | Verify passed | `ledger:ledger-ship` | `bash .ledger/bin/ledger.sh guard ship` |
| `verify-fail` | Verify failed | `ledger:ledger-build` | `bash .ledger/bin/ledger.sh guard build` |

**How to load a skill:** Use the `Skill` tool with the skill name.

**When to suggest phase transition:**
- After the current phase's skill completes, suggest entering the next phase
- Do NOT auto-advance — wait for user confirmation or let the skill handle it

## Guard Enforcement

```
NO PHASE ENTRY WITHOUT RUNNING GUARD FIRST
```

Before entering any phase (pid, contract, build, verify, ship):

1. Run the guard command from the table above
2. If guard passes → proceed
3. If guard fails → stop and explain why

Do NOT skip guard. Do NOT "assume it will pass." Run it.

Guard is side-effect-free — it only checks, never modifies state.

## Core Constraints

These rules apply at all times when Ledger is active:

### State Machine

- `.ledger/state.md` is the single source of truth for current phase
- Valid phase transitions: `待开始 → pid → contract → build → build-complete → verify → verify-pass / verify-fail → shipped`（verify-fail 可回退至 build）
- Do NOT skip phases
- Do NOT edit state.md directly unless the phase skill instructs you to
- Use `bash .ledger/bin/ledger.sh state set-phase <phase>` for state transitions

### Artifacts

- PID Card → `.ledger/specs/[feature]-pid.md`
- Contract → `.ledger/contracts/[feature].md`
- Verify Record → `.ledger/knowledge/[feature]-verify.md`
- Archive → `.ledger/contracts/archive/[feature].md`

Do NOT infer artifact content from chat history. Read the actual files.

### Evidence

- Verify verdict must be based on real command output
- Prohibited language in verify records: "应该", "预期", "理论上", "should", "expected", "theoretically"
- PASS verdict requires runtime evidence (actual command output captured)

### Constitution

- `.ledger/core/constitution.md` contains project-specific hard constraints
- These override any general coding practices
- Read constitution at session start and before build

## When Ledger Does NOT Apply

- Editing configuration files, README, docs (non-code changes)
- Quick fixes that don't change behavior
- Refactoring with no behavior change (but still run tests)
- User explicitly says "skip Ledger for this"

When in doubt, ask the user.

## Retro Schedule

After every 3-5 shipped features, suggest running `ledger:ledger-retro` to check:
- Intent drift
- Feature stacking signals
- Architecture boundary violations
- Pattern extraction opportunities

## Red Flags — STOP

| Thought | Reality |
|---------|---------|
| "This is too simple for Ledger" | Simple features still need intent and verification |
| "I'll skip the guard just this once" | Guard exists because agents skip steps |
| "The contract is obvious from context" | Obvious ≠ documented. Write it. |
| "Tests pass, so it's done" | Ledger verify requires adversarial evidence, not just test passage |
| "I can infer the PID from the chat" | PID must be a file, not a chat summary |
| "State.md doesn't need updating" | State drift breaks the entire protocol |
| "TDD is overkill for this FC" | TDD is mandatory for all FCs under Ledger |

## Relationship with Other Skills

Ledger skills are protocol skills — they govern *how* feature work happens.

Non-Ledger skills (TDD patterns, debugging techniques, code review) are implementation skills — they govern *how* to write code.

Ledger calls implementation skills when needed. For example, ledger-build may use TDD patterns during implementation. But Ledger protocol takes precedence over implementation preferences.

## Slash Commands

Ledger slash commands (`/ledger.pid`, `/ledger.build`, etc.) are shortcuts for loading the corresponding skill. They are equivalent to using the Skill tool with `ledger:ledger-pid`, `ledger:ledger-build`, etc.

If the user types a `/ledger.*` command, load the corresponding skill directly.
