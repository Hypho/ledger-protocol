# Using Ledger

Ledger is a protocol layer for AI-assisted software development. It does not replace your editor, agent, tests, git workflow, deployment pipeline, or product judgment.

Use it to keep feature work explicit:

```text
intent -> contract -> build -> verify -> ship
```

For Chinese, see [USAGE.zh.md](./USAGE.zh.md).

---

## 1. Choose Your Adapter

Ledger is tool-agnostic at the protocol layer, but different AI tools load project instructions differently.

| Tool | Recommended adapter | Support level |
|------|---------------------|---------------|
| Claude Code | Plugin + `.claude/commands/*.md` | First-class |

Claude Code users should install the Ledger plugin first (see [INSTALL.md](./INSTALL.md)). The plugin provides auto-triggering skills via a SessionStart hook.

Details:
- [Claude Code adapter](./docs/adapters/claude-code.md)

---

## 2. Install Into a Project

Detailed installation options: [INSTALL.md](./INSTALL.md)

Recommended remote installer:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.sh | bash -s -- --target . --mode auto
```

Windows PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.ps1 | iex"
```

This directly installs Ledger files into the target project.

If you are working from the Ledger source repository, you can also run the copy command from the repository root:

```bash
cp -r CLAUDE.md .claude .ledger your-project/
```

Or use the installer:

```bash
bash scripts/install-ledger.sh --target your-project --mode auto
```

On Windows PowerShell:

```powershell
.\scripts\install-ledger.ps1 -Target your-project -Mode auto
```

If you are copying from a parent directory that contains the cloned `Ledger/` folder, prefix the source paths:

```bash
cp -r Ledger/CLAUDE.md Ledger/.claude Ledger/.ledger your-project/
```

### File Set

```text
CLAUDE.md
.claude/commands/
.ledger/
```

---

## 3. Initialize the Project

In Claude Code:

```text
/ledger.init
/ledger.scope
```

What happens:
- `/ledger.init` creates project-level facts: constitution, Product Spine / PAD draft, and state.
- `/ledger.scope` assesses whether Ledger is appropriate and identifies risk boundaries.
- Scope is strongly recommended before the first feature, but it is not a state-machine phase.
- Fill the PAD with a product goal, core business flow, feature type definitions, core entities, and UX consistency rules before starting substantial feature work.

---

## 4. Develop One Feature

Run one feature through the main flow:

```text
/ledger.pid
/ledger.contract
/ledger.build
/ledger.verify
/ledger.ship
```

If your tool does not support slash commands, use natural-language equivalents:

```text
Create the Ledger PID Card for [feature].
Generate the behavior contract from the PID Card.
Build against the contract.
Verify the feature with real command output.
Ship and archive the feature after PASS.
```

Expected artifacts:

| Stage | Output |
|-------|--------|
| `pid` | `.ledger/specs/[feature]-pid.md` |
| `contract` | `.ledger/contracts/[feature].md` |
| `build` | Code changes + `state.md` moves to `build-complete` |
| `verify` | `.ledger/knowledge/[feature]-verify.md` |
| `ship` | Archived contract + updated state |

### Skills Auto-Routing

With the Ledger plugin installed, skills auto-route based on state:

| state.md phase | Skill loaded | What happens |
|----------------|--------------|--------------|
| (session start) | `using-ledger` | Detects `.ledger/`, reads state, routes to correct skill |
| `pid` | `ledger:ledger-pid` | Intent capture, boundary detection, PID Card generation |
| `contract` | `ledger:ledger-contract` | Behavior contract generation with complexity scoring |
| `build` | `ledger:ledger-build` | RED-GREEN-REFACTOR TDD for each FC entry |
| `build-complete` | `ledger:ledger-verify` | Subagent-driven adversarial verification |
| `verify-pass` | `ledger:ledger-ship` | Full test suite, acceptance, archive |

Without the plugin, follow the same protocol manually via slash commands or natural language.

### Complexity Scoring

Ledger 2.x replaces the fixed 7-FC limit with a complexity scoring model:

| Score | Build approach |
|-------|---------------|
| ≤8 | Direct build |
| 9-12 | Component plan (required) |
| 13-16 | Execution plan (required) |
| >16 | Must split the feature |

Each dimension (edge cases, dependencies, state transitions, cross-module impact) is scored 1-3.

Global Spine Lite adds two lightweight global anchors without adding daily workflow steps:

| Spine | File | Purpose |
|-------|------|---------|
| Product Spine | `.ledger/specs/PAD.md` | Product goal, core business flow, entities, states, UX consistency, feature type definitions |
| Architecture Spine | `.ledger/core/architecture.md` | Module boundaries, entity ownership, state machine ownership, permission location, dependency direction, ADR triggers |

During `/ledger.pid`, map the feature to a PAD flow step or mark it as auxiliary, admin, or experimental with a reason. During `/ledger.build`, check implementation against the relevant architecture boundaries.

---

## 5. When Ledger Stops

Ledger should stop instead of guessing when:

- a high-risk boundary is detected
- a required PID Card, contract, or verify record is missing
- contract lint or verify lint fails
- verify is `FAIL` or `INCONCLUSIVE`
- manual acceptance is required
- a large feature needs an execution plan
- complexity score > 16 (feature must be split)

Use the stop as a decision point. Do not treat it as an error to bypass.

---

## 6. Maintain the Project

Every 3-5 shipped features, run:

```text
/ledger.retro
```

Use `.ledger/knowledge/patterns.md` for reusable engineering knowledge that remains useful across features and sessions:

- module conventions
- non-obvious dependencies
- testing approaches
- recurring gotchas

Promote stable learnings during `/ledger.ship` and clean stale entries during `/ledger.retro`. Do not use `patterns.md` as a progress log, debug scratchpad, or replacement for `constitution.md` or module handover files.

Before publishing or sharing framework changes:

```bash
bash .ledger/bin/ledger-check.sh
```

Inside an installed project:

```bash
bash .ledger/bin/ledger.sh check --project
```

To validate or update Ledger state through the controlled entry:

```bash
bash .ledger/bin/ledger.sh state validate
bash .ledger/bin/ledger.sh state enqueue <feature>
bash .ledger/bin/ledger.sh state set-phase <phase>
bash .ledger/bin/ledger.sh state complete
bash .ledger/bin/ledger.sh state fail-verify
```

To diagnose stale state without changing files:

```bash
bash .ledger/bin/ledger.sh check --stale
```

To check Global Spine Lite artifacts:

```bash
bash .ledger/bin/ledger.sh lint-pad .ledger/specs/PAD.md
bash .ledger/bin/ledger.sh lint-architecture .ledger/core/architecture.md
bash .ledger/bin/ledger.sh lint-pid --all
```

If the project adopts Ledger's release layer with `VERSION` and `CHANGELOG.md`:

```bash
bash .ledger/bin/ledger-release-check.sh
```

---

## 7. Release Discipline

Ledger does not require a version bump for every documentation or rule edit.

Use releases only when the change set has clear release value:
- `PATCH`: refinements to existing behavior, docs, templates, or checks
- `MINOR`: a complete new capability
- `MAJOR`: incompatible protocol or state-machine changes

Release notes come from `CHANGELOG.md`.

---

## 8. Further References

- Concept guide: [Global Spine Lite](./docs/concepts/global-spine-lite.md).
- Concept guide: [Design Attachments Lite](./docs/concepts/design-attachments-lite.md).
- Existing projects can adopt the new fields with [Adopt Global Spine Lite](./docs/migration/adopt-global-spine-lite.md).
- For runnable sample flows, see [examples](./examples/).
- For the core workflow reference, see [.ledger/core/workflow.md](./.ledger/core/workflow.md).
