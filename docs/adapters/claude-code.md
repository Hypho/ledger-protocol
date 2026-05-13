# Claude Code Adapter

Claude Code is the first-class Ledger runtime. Ledger 2.x provides a Claude Code plugin with auto-triggering skills and session hooks.

## Plugin Installation (Recommended)

```bash
# Register the Ledger marketplace
claude plugin marketplace add https://github.com/Hypho/ledger-protocol

# Install the plugin
claude plugin install ledger@ledger
```

After installation, open a new session in a project with `.ledger/`. The SessionStart hook auto-injects `using-ledger` into context.

### What the plugin provides

| Component | Location | Purpose |
|-----------|----------|---------|
| Skills | `skills/ledger-*/SKILL.md` | Phase-specific protocol guidance |
| SessionStart hook | `hooks/session-start` | Auto-detects `.ledger/`, injects `using-ledger` |
| Guard scripts | `ledger-core/runtime/bin/` | Phase entry enforcement |

### Skills

| Skill | Phase | Auto-triggers when |
|-------|-------|--------------------|
| `using-ledger` | Session start | `.ledger/` exists in project |
| `ledger-scope` | Pre-feature | Loaded via `/ledger.scope` or Skill tool |
| `ledger-pid` | pid | `state.md` phase = `pid` |
| `ledger-contract` | contract | `state.md` phase = `contract` |
| `ledger-build` | build | `state.md` phase = `build` |
| `ledger-verify` | verify | `state.md` phase = `build-complete` |
| `ledger-ship` | ship | `state.md` phase = `verify-pass` |
| `ledger-retro` | retro | Every 3-5 features |

## Script Installation (Alternative)

For environments without plugin support, or if you prefer file-based installation:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.sh | bash -s -- --target your-project --mode claude
```

From the Ledger repository root:

```text
CLAUDE.md
.claude/commands/
.ledger/
```

```bash
cp -r CLAUDE.md .claude .ledger your-project/
```

Script installation copies protocol files into the project but does not provide auto-triggering skills or SessionStart hooks. Follow `CLAUDE.md` and slash commands manually.

## Slash Commands

Both plugin and script installations provide slash commands:

```text
/ledger.init
/ledger.scope
/ledger.pid
/ledger.contract
/ledger.build
/ledger.verify
/ledger.ship
/ledger.retro
```

With the plugin installed, slash commands load the corresponding skill via the Skill tool. Without the plugin, they execute as standalone protocol files.

## Guard Scripts

The command files instruct Claude Code to run:

```bash
bash .ledger/bin/ledger-guard.sh <pid|contract|build|verify|ship>
```

You can also run the guard manually when debugging state issues.
