# Changelog

All notable changes to Ledger are documented here.

Ledger follows semantic versioning: `MAJOR.MINOR.PATCH`.

This changelog follows a Keep a Changelog style:
- newest releases first
- each release uses `## vX.Y.Z — YYYY-MM-DD`
- changes are grouped under `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, and `Security`
- empty groups are omitted
- entries describe user- or maintainer-visible changes, not raw commit history

---

## v0.1.0 — 2026-05-13

Initial public release of Ledger.

### Core Protocol
- `pid → contract → build → verify → ship` feature lifecycle with guard enforcement.
- File-based state machine in `.ledger/state.md`.
- Complexity scoring model (4 dimensions × 1–3, thresholds at 8/12/16) replacing fixed FC limits.
- Subagent-driven adversarial verification with FC independence analysis.
- Command entry guards for all lifecycle phases.

### Skills Architecture
- Auto-injecting skills via SessionStart hook (Claude Code plugin).
- Skills: `using-ledger`, `ledger-scope`, `ledger-pid`, `ledger-contract`, `ledger-build`, `ledger-verify`, `ledger-ship`, `ledger-retro`.

### Global Spine Lite
- Product Spine in `.ledger/specs/PAD.md`.
- Architecture Spine in `.ledger/core/architecture.md`.
- PID flow mapping and architecture impact checks.

### Quality Checks
- Contract lint, verify lint, PAD lint, architecture lint, PID lint, design lint.
- State consistency validation and stale diagnostics.
- Controlled state mutation via `ledger.sh state` commands.

### Documentation
- English and Chinese README, INSTALL, USAGE guides.
- Claude Code adapter docs.
- Runnable examples: `todo-feature`, `secure-notes`, `order-flow`.
