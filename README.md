# Ledger — Auditable AI-Assisted Development Protocol
> A lightweight protocol framework for auditable human-AI software development | v0.1.0
> 中文: [README.zh.md](./README.zh.md)

[![Ledger Check](https://github.com/Hypho/ledger-protocol/actions/workflows/ledger-check.yml/badge.svg)](https://github.com/Hypho/ledger-protocol/actions/workflows/ledger-check.yml)

---

## What is it

Ledger is a lightweight protocol framework for building software with AI while keeping product intent, implementation scope, and verification evidence explicit.

It turns AI-assisted development from an open-ended chat into a staged workflow: define intent, write a behavior contract, implement against that contract, verify with real outputs, then archive what changed.

Ledger keeps the daily feature loop lightweight, but feature work is anchored by two global spines: the Product Spine in `PAD.md` and the Architecture Spine in `architecture.md`. A feature should explain where it fits in the core business flow and which module / entity boundaries it touches before it enters build.

Ledger is designed for product-minded builders, solo developers, and small teams who want AI to move faster without losing control of scope, state, and quality.

It is not a code generator, an agent scheduler, or a replacement for CI/CD. It is the protocol layer that keeps human decisions and AI execution aligned.

Core idea: **Define behavior before implementation. Verify behavior before shipping.**

---

## Skills System

Ledger 2.x uses a skills-based architecture. Skills are composable protocol documents that guide the agent through each phase. They auto-trigger based on project state.

| Skill | Phase | Purpose |
|-------|-------|---------|
| `using-ledger` | Session start | State awareness, phase routing, guard enforcement |
| `ledger-scope` | Pre-feature | Ledger applicability assessment |
| `ledger-pid` | pid | Intent definition + boundary detection |
| `ledger-contract` | contract | Behavior contract generation |
| `ledger-build` | build | TDD implementation with complexity scoring |
| `ledger-verify` | verify | Subagent-driven adversarial verification |
| `ledger-ship` | ship | Test suite, acceptance, archive |
| `ledger-retro` | Every 3-5 features | Protocol quality review |

**How it works:**
- A SessionStart hook detects `.ledger/` in the project and injects `using-ledger` into the agent context
- The agent reads `state.md` to determine the current phase
- The matching skill is loaded automatically or via the Skill tool
- Guards enforce phase entry requirements before execution

In Claude Code, skills are provided via a plugin.

---

## When to use Ledger

Use Ledger when:

- You are building a product with AI assistance and need the work to remain auditable.
- You want clear handoffs between product intent, implementation, verification, and release.
- You are a solo developer, product-minded builder, or small team working feature by feature.
- You prefer explicit contracts and checkpoints over relying on long prompts.

Avoid Ledger when:

- You need a general-purpose task manager or multi-agent scheduler.
- You need deployment, monitoring, incident response, or CI/CD orchestration.
- You are solving high-risk security, financial, concurrency, or performance problems without specialist review.

---

## Scope

Before adopting, check whether your project falls within Ledger's applicable scope.

### Detected but not solved (framework halts, expects external specialist input)

- **Transaction consistency and concurrency races** — boundaries B-H02 / B-H05
- **Financial operations and sensitive data** — boundaries B-H03 / B-H06
- **Cross-user aggregation / real-time communication** — boundaries B-H01 / B-H04
- **Code performance (N+1, slow queries, etc.)** — runtime boundary scan in `/ledger.build`

> Ledger will actively stop you in these situations but does not propose solutions. Pair with specialized reviews (security / performance / DBA).
> The detect-and-halt behavior is itself one of the framework's deliverables.

### Entirely outside framework scope

- **Production deployment, monitoring, alerting**
- **Multi-developer concurrent development conflicts**
- **CI/CD pipelines and release management**

> Ledger does not engage with these — use other toolchains.

---

## Quick Start

Install details: [INSTALL.md](./INSTALL.md)
Full usage guide: [USAGE.md](./USAGE.md)
Global Spine Lite guide: [docs/concepts/global-spine-lite.md](./docs/concepts/global-spine-lite.md)
Design Attachments Lite guide: [docs/concepts/design-attachments-lite.md](./docs/concepts/design-attachments-lite.md)
Existing project adoption: [docs/migration/adopt-global-spine-lite.md](./docs/migration/adopt-global-spine-lite.md)

```bash
# Recommended: install directly into a project from GitHub
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.sh | bash -s -- --target your-project --mode auto

# Windows PowerShell: install into the current directory
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.ps1 | iex"

# From a cloned Ledger repository
bash scripts/install-ledger.sh --target your-project --mode auto

# In Claude Code, run:
/ledger.init    # Project initialization (one-time)
/ledger.scope   # Scope and risk-boundary assessment (recommended before first feature)

# Optional installed-project self-check
cd your-project
bash .ledger/bin/ledger.sh check --project

# Framework maintainers: see RELEASE.md for release checks
```

The remote installer copies Ledger files directly into the target project. Runtime checks still require `bash`.

### Claude Code Plugin Installation (Recommended)

Ledger is available as a Claude Code plugin:

```bash
# Register the Ledger marketplace
claude plugin marketplace add https://github.com/Hypho/ledger-protocol

# Install the plugin
claude plugin install ledger@ledger
```

After installation, Ledger skills auto-inject on session start when `.ledger/` exists in the project.

---

## Tool Support

Ledger is tool-agnostic at the protocol layer. Each tool uses its native instruction and skill mechanism.

| Tool | Support | Mechanism | Entry point |
|------|---------|-----------|-------------|
| Claude Code | First-class | Plugin + skills + SessionStart hook | [docs/adapters/claude-code.md](./docs/adapters/claude-code.md) |

`CLAUDE.md` is the Claude Code runtime entry. `.ledger/core/workflow.md` and `.ledger/core/constitution.md` remain the source files for workflow facts and hard constraints.

Claude Code users can install Ledger as a plugin for automatic skill injection.

---

## Examples

See [examples](./examples/) for runnable completed feature flows:

- [todo-feature](./examples/todo-feature/) shows the smallest useful flow with validation and storage failure handling.
- [secure-notes](./examples/secure-notes/) shows a more realistic ownership boundary with denied cross-user access and verification evidence.
- [order-flow](./examples/order-flow/) shows Global Spine Lite: PAD business flow, architecture boundaries, PID flow mapping, and flow evidence in verify.

---

## Execution Model

Per-feature flow: `pid → contract → build → verify → ship`

Every 3–5 features: `retro`

The canonical workflow definition is [.ledger/core/workflow.md](./.ledger/core/workflow.md). README, adapter files, and command files should summarize that reference instead of redefining a different flow.

---

## Commands

| Command | When | Skill | Responsibility |
|---------|------|-------|----------------|
| `/ledger.init` | Project start (one-time) | — | Interactive init; generates constitution, PAD draft, state |
| `/ledger.scope` | Recommended before first feature | `ledger:ledger-scope` | Ledger applicability and risk-boundary assessment |
| `/ledger.pid` | Each feature start | `ledger:ledger-pid` | Define feature intent, run boundary detection, generate PID Card |
| `/ledger.contract` | After pid | `ledger:ledger-contract` | Generate behavior contract (FC/NF entries) as baseline for build and verify |
| `/ledger.build` | After contract | `ledger:ledger-build` | TDD implementation with complexity scoring |
| `/ledger.verify` | After build | `ledger:ledger-verify` | Subagent-driven adversarial verification with real runtime output |
| `/ledger.ship` | After verify PASS | `ledger:ledger-ship` | Smoke tests, record completion, archive contract |
| `/ledger.retro` | Every 3–5 features | `ledger:ledger-retro` | Review contract quality, clean up technical debt |

---

## Directory Structure

```
your-project/
├── CLAUDE.md                        ← Hot layer, auto-loaded at session start
│                                      Contains: startup sequence / execution model / commands / file assembly rules
├── .claude/
│   └── commands/                    ← 8 command files (per-command protocols)
│       ├── ledger.init.md
│       ├── ledger.scope.md
│       ├── ledger.pid.md
│       ├── ledger.contract.md
│       ├── ledger.build.md
│       ├── ledger.ship.md
│       ├── ledger.verify.md
│       └── ledger.retro.md
└── .ledger/
    ├── state.md                     ← Hot layer, cross-session state machine
    ├── core/
    │   ├── constitution.md          ← Warm layer: project charter, hard constraints + file-naming rules
    │   └── architecture.md          ← Cold layer: load on demand
    ├── schemas/
    │   ├── state.schema.json        ← Draft structured state schema for future migration
    │   └── queue.schema.json        ← Draft structured queue schema, not active in v1.x
    ├── state.example.json           ← Example only, not a runtime source
    ├── queue.example.json           ← Example only, not a runtime source
    ├── scope/
    │   ├── boundaries.md            ← Boundary checklist (B-H / B-M risk rules)
    │   └── fitness.md               ← Adaptation assessment output (/ledger.scope)
    ├── specs/                       ← Project instances (generated by commands, not blank templates)
    │   ├── PAD.md                   ← Product Architecture Document (/ledger.init draft)
    │   ├── FDG.md                   ← Optional Feature Dependency Graph (/ledger.scope, explicit opt-in)
    │   └── [feature]-pid.md         ← Per-feature PID Cards (/ledger.pid)
    ├── contracts/                   ← Behavior contracts
    │   ├── [feature].md             ← Active feature contract
    │   └── archive/                 ← Completed contracts (/ledger.ship)
    ├── templates/                   ← Blank reference templates (never filled directly)
    │   ├── PAD.md / FDG.md / IFD.md
    │   ├── pid-card.md / contract.md / verify.md
    │   ├── exec-plan.md / handover.md
    │   └── README.md
    ├── hooks/
    │   └── check-state.sh           ← SessionStart hook (validates state.md vs filesystem)
    ├── exec-plans/
    │   ├── active/                  ← Active large-feature plans
    │   └── completed/
    ├── knowledge/
    │   ├── [feature]-verify.md      ← Verify record (verdict + adversarial test results)
    │   ├── tech-debt.md             ← Technical debt tracking
    │   ├── decisions/               ← Architecture decision archive
    │   ├── errors/                  ← Failure records
    │   ├── handover/
    │   └── archive/                 ← Historical state / completed feature archive
    └── tests/
        ├── features/
        ├── fixtures/
        └── api/
```

### Plugin Structure (installed separately)

The Ledger plugin provides skills and hooks. It is installed via `claude plugin install` and lives in the Claude Code plugin cache, not in the project directory:

```text
~/.claude/plugins/cache/ledger/ledger/<version>/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── hooks/
│   ├── hooks.json
│   ├── session-start
│   └── run-hook.cmd
└── skills/
    ├── using-ledger/SKILL.md
    ├── ledger-scope/SKILL.md
    ├── ledger-pid/SKILL.md
    ├── ledger-contract/SKILL.md
    ├── ledger-build/SKILL.md
    ├── ledger-verify/SKILL.md
    ├── ledger-ship/SKILL.md
    └── ledger-retro/SKILL.md
```

The project directory only contains data (`.ledger/`) and the entry file (`CLAUDE.md`). The plugin provides runtime guidance.

---

## Key Mechanisms

### File Naming Convention
All contract / verify / exec-plan / pid-card paths are derived from the feature-name field in state.md, following rules defined in constitution.md. The startup check compares the phase declared in state.md against the corresponding files; mismatch halts execution.

### Global Spine Lite

Ledger adds global constraints without adding daily workflow steps:

- `PAD.md` is the Product Spine: product goal, core users and scenarios, core business flow, core entities and states, UX consistency rules, and feature type definitions.
- `architecture.md` is the Architecture Spine: architecture principles, module boundaries, entity ownership, state machine ownership, permission location, write boundaries, dependency direction, and ADR triggers.
- PID Cards map each feature to a PAD flow step or explicitly mark it as auxiliary, admin, or experimental.
- Build checks implementation against the Architecture Spine when a feature touches modules, entities, state machines, permissions, or dependencies.

This is not a PRD system or architecture governance platform. It is a lightweight global constraint layer for the existing `pid -> contract -> build -> verify -> ship` loop.

### State Source
In v1.x, `.ledger/state.md` remains the human-readable source of truth. Ledger also includes a draft `.ledger/schemas/state.schema.json` to define the future structured state shape, but it does not change the current runtime behavior.

Ledger also includes draft-only structured examples for future migration: `.ledger/state.example.json`, `.ledger/schemas/queue.schema.json`, and `.ledger/queue.example.json`. These are not runtime truth sources in v1.x.

State changes that tools need to perform should go through the controlled state entry:

```bash
bash .ledger/bin/ledger.sh state validate
bash .ledger/bin/ledger.sh state enqueue <feature>
bash .ledger/bin/ledger.sh state set-phase <phase>
bash .ledger/bin/ledger.sh state complete
bash .ledger/bin/ledger.sh state fail-verify
```

`ledger-check.sh` validates the basic `state.md` structure, runs logical consistency checks, and covers common invalid states with fixtures.

For time-based health diagnostics, run:

```bash
bash .ledger/bin/ledger.sh check --stale
```

### Contract / Verify Lint
Ledger checks that behavior contracts and verification records are structurally valid:

- contracts must include FC entries and explicit out-of-scope boundaries
- contracts must not contain obvious template placeholders
- verify records must include exactly one strict `verdict = PASS|FAIL|INCONCLUSIVE` line
- verify records reject speculative language such as "should", "expected", and "theoretically"
- PASS verify records must include a runtime evidence marker such as `output:` or `command:`

### Command Guard
Ledger includes a command guard that checks whether a `/ledger.*` command is allowed to start based on `state.md` and required artifacts.

```bash
bash .ledger/bin/ledger-guard.sh pid
bash .ledger/bin/ledger-guard.sh contract
bash .ledger/bin/ledger-guard.sh build
bash .ledger/bin/ledger-guard.sh verify
bash .ledger/bin/ledger-guard.sh ship
```

The guard does not execute commands, generate files, or modify state. It only reports whether the command may start.

### Global Spine Lite Checks

```bash
bash .ledger/bin/ledger.sh lint-pad <file>
bash .ledger/bin/ledger.sh lint-architecture <file>
bash .ledger/bin/ledger.sh lint-pid <file|--all>
```

These are lightweight structure checks. They do not grade product quality, UX quality, or architecture quality.

### Scope Assessment

`/ledger.scope` checks whether Ledger is appropriate for the project and identifies risk boundaries before feature work starts.

It outputs one of three usage modes:

- `Ledger-only`
- `Ledger + specialist review`
- `Do not use Ledger alone`

FDG generation is optional. It should only be generated when the developer explicitly provides 3+ known features and wants dependency planning.

### Boundary Detection
`/ledger.pid` scans the current feature against boundaries.md:

| Level | Scope | Response |
|-------|-------|----------|
| High risk (B-H) | Real-time comms / concurrent writes / financial ops / cross-user aggregation / multi-table transactions / sensitive data | Hard halt, wait for human decision |
| Mid risk (B-M) | Complex permissions / file handling / third-party integration / async tasks / complex queries / schema changes | Advisory note, may continue |

Large-feature gating (spans 3+ modules / schema changes / needs 2+ sessions / depends on 3+ unfinished features) → mandatory execution plan, requires human confirmation.

### Feature Sizing
Ledger now treats feature size as a protocol concern. A feature should fit one complete `contract -> build -> verify -> ship` loop. `/ledger.pid` flags broad work early. A complexity scoring model evaluates each feature across four dimensions (edge cases, dependencies, state transitions, cross-module impact), each scored 1-3. Total score determines the build approach: ≤8 direct build, 9-12 component plan, 13-16 execution plan, >16 must split.

### Reusable Patterns
Durable cross-feature engineering knowledge belongs in `.ledger/knowledge/patterns.md`. `/ledger.ship` may promote stable learnings into this file, and `/ledger.retro` cleans stale or story-specific entries. It is not a progress log or a replacement for module handover files.

### Verify Mechanism
Not code review, but active falsification. For each FC entry, construct edge inputs, run them for real, capture real output; inferential language is prohibited. Three possible verdicts: `PASS` / `FAIL` (roll back to build) / `INCONCLUSIVE` (triaged via a three-option protocol).

In 2.x, verification uses subagent-driven development: each FC entry is dispatched to an independent subagent for adversarial testing, then a reviewer evaluates evidence quality.

---

## Versioning Rules

Semantic versioning: `MAJOR.MINOR.PATCH`

| Position | Trigger | Typical change |
|----------|---------|----------------|
| **MAJOR** | Breaking protocol change; initialized projects cannot upgrade smoothly | Commands added/removed/renamed; state-machine phase changes; file-naming rule changes; directory restructure |
| **MINOR** | Backward-compatible protocol extension | New optional Step or check; new template; new non-mandatory sub-protocol; hook capability enhancement |
| **PATCH** | No new standalone capability | Wording / typo fixes; internal consistency fixes; responsibility narrowing; template alignment; small adjustments to existing checks |

> Version numbers change only for release-worthy change sets. Small edits may accumulate in local work or normal commits before a release.
> Milestones get git tags (`v1.0.0`, `v1.1.0`, `v2.0.0`).
> Keep the last 10 entries in the table below; older entries move to `CHANGELOG.md`.

---

## Version History

Detailed release notes are maintained in [CHANGELOG.md](./CHANGELOG.md).
Release process details are documented in [RELEASE.md](./RELEASE.md).

| Version | Date | Core changes |
|---------|------|--------------|
| v0.1.0 | 2026-05-13 | Initial public release. Skills-based architecture, complexity scoring, subagent-driven verification, Claude Code plugin architecture |
