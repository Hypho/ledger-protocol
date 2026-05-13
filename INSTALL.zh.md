# 安装 Ledger

Ledger 会把框架文件安装到目标项目目录。

## Claude Code Plugin（推荐 Claude Code 用户使用）

Ledger 2.x 可作为 Claude Code plugin 安装。Plugin 提供 skills（自动触发的协议引导）和 hooks（会话启动注入）。

```bash
# 注册 Ledger marketplace
claude plugin marketplace add https://github.com/Hypho/ledger-protocol

# 安装 plugin
claude plugin install ledger@ledger
```

安装后，在包含 `.ledger/` 的项目中打开新会话，SessionStart hook 会自动检测 Ledger 并将 `using-ledger` skill 注入上下文。

### 验证安装

```bash
# 检查 plugin 是否注册
claude plugin list | grep ledger

# 在新会话中，using-ledger skill 应自动注入
# 也可以手动加载 skill：使用 Skill 工具加载 ledger:ledger-build
```

### Plugin vs 脚本安装

| 方面 | Plugin | 脚本 |
|------|--------|------|
| Skills | 通过 SessionStart hook 自动注入 | 不可用；手动遵循 CLAUDE.md |
| Guards | 通过 `bash .ledger/bin/ledger.sh guard` 可用 | 相同 |
| 平台 | 仅 Claude Code | 任何支持 bash 的工具 |
| 更新 | `claude plugin update ledger@ledger` | 重新运行安装器 |

其他工具请使用下方脚本安装方式。

---

## 最新 main

Bash / Git Bash / WSL：

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.sh | bash -s -- --target . --mode auto
```

Windows PowerShell，安装到当前目录：

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.ps1 | iex"
```

Windows PowerShell，指定目标目录：

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target your-project -Mode auto -Ref main
Remove-Item $installer
```

## 固定版本

Bash / Git Bash / WSL：

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/v1.8.0/scripts/install-from-github.sh | bash -s -- --target . --mode auto --ref v1.8.0
```

Windows PowerShell：

```powershell
$installer = Join-Path $env:TEMP "install-from-github.ps1"
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/Hypho/ledger-protocol/v1.8.0/scripts/install-from-github.ps1" -OutFile $installer
powershell -ExecutionPolicy Bypass -File $installer -Target . -Mode auto -Ref v1.8.0
Remove-Item $installer
```

## 模式

| 模式 | 安装内容 |
|------|----------|
| `auto` | 根据已有项目文件选择模式；没有明显信号时默认 `all` |
| `all` | `CLAUDE.md`、`.claude/`、`.ledger/` |
| `claude` | `CLAUDE.md`、`.claude/`、`.ledger/` |

> **注意：** `auto` 模式不会安装 Claude Code plugin。Plugin 安装是上面描述的独立步骤。脚本安装将文件复制到项目目录；plugin 安装由 Claude Code 管理。

## 自检

安装后，在目标项目根目录执行：

```bash
bash .ledger/bin/ledger.sh check --project
```

Windows PowerShell 中请先进入目标目录再执行：

```powershell
Set-Location your-project
bash .ledger/bin/ledger.sh check --project
```

不要把 `C:\path\project\.ledger\bin\ledger.sh` 这样的 Windows 绝对路径直接传给 `bash`；Git Bash 和 WSL 对路径的解析不同。先进入项目目录，或在 WSL 中使用 `/mnt/c/path/project` 这样的 POSIX 路径。
