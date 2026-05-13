# Install Ledger

Ledger installs framework files into a target project directory.

## Claude Code Plugin (Recommended for Claude Code Users)

Ledger 2.x is available as a Claude Code plugin. The plugin provides skills (auto-triggering protocol guidance) and hooks (session start injection).

```bash
# Register the Ledger marketplace
claude plugin marketplace add https://github.com/Hypho/ledger-protocol

# Install the plugin
claude plugin install ledger@ledger
```

After installation, open a new session in a project that contains `.ledger/`. The SessionStart hook will automatically detect Ledger and inject the `using-ledger` skill into context.

### Verifying Installation

```bash
# Check plugin is registered
claude plugin list | grep ledger

# In a new session, the using-ledger skill should auto-inject
# You can also manually load skills:
# Use the Skill tool to load ledger:ledger-build
```

### Plugin vs Script Installation

| Aspect | Plugin | Script |
|--------|--------|--------|
| Skills | Auto-injected via SessionStart hook | Not available; follow CLAUDE.md manually |
| Guards | Available via `bash .ledger/bin/ledger.sh guard` | Same |
| Platform | Claude Code only | Any tool with bash |
| Updates | `claude plugin update ledger@ledger` | Re-run installer |

For other tools, use the script-based installation below.

---

## Latest Main

Bash / Git Bash / WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.sh | bash -s -- --target . --mode auto
```

Windows PowerShell, current directory:

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.ps1 | iex"
```

Windows PowerShell, explicit target:

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target your-project -Mode auto -Ref main
Remove-Item $installer
```

## Fixed Release

Bash / Git Bash / WSL:

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/v1.8.0/scripts/install-from-github.sh | bash -s -- --target . --mode auto --ref v1.8.0
```

Windows PowerShell:

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/ledger-protocol/v1.8.0/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target . -Mode auto -Ref v1.8.0
Remove-Item $installer
```

## Modes

| Mode | Installs |
|------|----------|
| `auto` | Selects a mode from existing project files; defaults to `all` |
| `all` | `CLAUDE.md`, `.claude/`, `.ledger/` |
| `claude` | `CLAUDE.md`, `.claude/`, `.ledger/` |

> **Note:** The `auto` mode does not install the Claude Code plugin. Plugin installation is a separate step described above. Script-based installation copies files into the project directory; plugin installation is managed by Claude Code.

## Self-Check

After installation, run from the target project root:

```bash
bash .ledger/bin/ledger.sh check --project
```

On Windows PowerShell, run the check after changing into the target directory:

```powershell
Set-Location your-project
bash .ledger/bin/ledger.sh check --project
```

Do not pass a Windows absolute path such as `C:\path\project\.ledger\bin\ledger.sh` directly to `bash`; Git Bash and WSL parse those paths differently. Enter the project directory first, or use a POSIX path such as `/mnt/c/path/project` when running from WSL.
