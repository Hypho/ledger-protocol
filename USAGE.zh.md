# 使用 Ledger

Ledger 是一层面向 AI 辅助软件开发的协议，不替代编辑器、agent、测试、git、部署流水线或产品判断。

它的作用是让功能开发保持显式：

```text
意图 -> 契约 -> 实现 -> 验证 -> 发布归档
```

English: [USAGE.md](./USAGE.md)

---

## 1. 选择适配方式

Ledger 的协议层不绑定具体工具，但不同 AI 工具读取项目规则的方式不同。

| 工具 | 推荐适配方式 | 支持程度 |
|------|-------------|---------|
| Claude Code | Plugin + `.claude/commands/*.md` | 一等支持 |

Claude Code 用户应先安装 Ledger plugin（见 [INSTALL.zh.md](./INSTALL.zh.md)）。Plugin 通过 SessionStart hook 提供自动触发的 skills。

详细说明：
- [Claude Code 适配](./docs/adapters/claude-code.md)

---

## 2. 安装到项目

详细安装选项：[INSTALL.zh.md](./INSTALL.zh.md)

推荐使用远程安装器：

```bash
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.sh | bash -s -- --target . --mode auto
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.ps1 | iex"
```

这种方式会直接把 Ledger 文件安装到目标项目目录。

如果你正在使用 Ledger 源码仓库，也可以在仓库根目录执行复制命令：

```bash
cp -r CLAUDE.md .claude .ledger your-project/
```

或使用安装脚本：

```bash
bash scripts/install-ledger.sh --target your-project --mode auto
```

Windows PowerShell：

```powershell
.\scripts\install-ledger.ps1 -Target your-project -Mode auto
```

如果你在包含 `Ledger/` 克隆目录的父目录中复制，需要给源路径加上 `Ledger/` 前缀：

```bash
cp -r Ledger/CLAUDE.md Ledger/.claude Ledger/.ledger your-project/
```

### 文件集合

```text
CLAUDE.md
.claude/commands/
.ledger/
```

---

## 3. 初始化项目

在 Claude Code 中：

```text
/ledger.init
/ledger.scope
```

结果：
- `/ledger.init` 建立项目级事实：constitution、Product Spine / PAD 初稿、state。
- `/ledger.scope` 判断 Ledger 是否适合当前项目，并识别风险边界。
- scope 建议在第一个功能前执行，但它不是状态机阶段。
- 在正式功能开发前，建议补齐 PAD 中的产品目标、核心业务主流程、功能类型定义、核心实体和体验一致性规则。

---

## 4. 开发一个功能

一个功能按主流程推进：

```text
/ledger.pid
/ledger.contract
/ledger.build
/ledger.verify
/ledger.ship
```

如果工具不支持 slash commands，使用自然语言等价指令：

```text
为 [功能名] 创建 Ledger PID Card。
根据 PID Card 生成行为契约。
按契约实现功能。
用真实命令输出验证功能。
PASS 后发布归档该功能。
```

预期产物：

| 阶段 | 产物 |
|------|------|
| `pid` | `.ledger/specs/[功能名]-pid.md` |
| `contract` | `.ledger/contracts/[功能名].md` |
| `build` | 代码变更 + `state.md` 进入 `build-complete` |
| `verify` | `.ledger/knowledge/[功能名]-verify.md` |
| `ship` | 归档 contract + 更新 state |

### Skills 自动路由

安装 Ledger plugin 后，skills 根据 state 自动路由：

| state.md 阶段 | 加载的 Skill | 作用 |
|---------------|-------------|------|
| （会话启动） | `using-ledger` | 检测 `.ledger/`，读取 state，路由到对应 skill |
| `pid` | `ledger:ledger-pid` | 意图捕获、边界检测、PID Card 生成 |
| `contract` | `ledger:ledger-contract` | 行为契约生成 + 复杂度评分 |
| `build` | `ledger:ledger-build` | 每个 FC 条目的 RED-GREEN-REFACTOR TDD |
| `build-complete` | `ledger:ledger-verify` | 子 Agent 驱动的对抗性验证 |
| `verify-pass` | `ledger:ledger-ship` | 完整测试、验收、归档 |

没有 plugin 时，通过 slash commands 或自然语言手动遵循相同协议。

### 复杂度评分

Ledger 2.x 用复杂度评分模型替代固定的 7-FC 限制：

| 评分 | 构建策略 |
|------|---------|
| ≤8 | 直接构建 |
| 9-12 | 组件计划（必须） |
| 13-16 | 执行计划（必须） |
| >16 | 必须拆分功能 |

每个维度（边界情况、依赖关系、状态转换、跨模块影响）各打 1-3 分。

Global Spine Lite 在不增加日常流程步骤的前提下增加两个全局锚点：

| 主干 | 文件 | 作用 |
|------|------|------|
| Product Spine | `.ledger/specs/PAD.md` | 产品目标、核心业务主流程、实体、状态、体验一致性、功能类型 |
| Architecture Spine | `.ledger/core/architecture.md` | 模块边界、实体归属、状态机归属、权限判断位置、依赖方向、ADR 触发条件 |

执行 `/ledger.pid` 时，功能应映射到 PAD 的业务主流程 Step，或标记为辅助 / 管理 / 实验并说明理由。执行 `/ledger.build` 时，对照相关 architecture 边界检查实现。

---

## 5. 什么时候暂停

Ledger 在以下情况应该暂停，而不是继续猜：

- 命中高风险边界
- 缺少 PID Card、contract 或 verify 记录
- contract lint 或 verify lint 失败
- verify 为 `FAIL` 或 `INCONCLUSIVE`
- 需要人工验收
- 大功能需要执行计划
- 复杂度评分 > 16（功能必须拆分）

暂停是决策点，不是要绕过的错误。

---

## 6. 日常维护

每完成 3-5 个功能，执行：

```text
/ledger.retro
```

`.ledger/knowledge/patterns.md` 用来记录跨功能、跨会话仍然有效的工程知识：

- 模块约定
- 非显然依赖
- 测试方式
- 常见陷阱

稳定经验可在 `/ledger.ship` 时沉淀，过时内容在 `/ledger.retro` 中清理。不要把 `patterns.md` 当作进度日志、debug 草稿，或替代 `constitution.md`、模块 handover。

发布或共享框架变更前：

```bash
bash .ledger/bin/ledger-check.sh
```

在已安装 Ledger 的业务项目中：

```bash
bash .ledger/bin/ledger.sh check --project
```

通过受控入口校验或更新 Ledger 状态：

```bash
bash .ledger/bin/ledger.sh state validate
bash .ledger/bin/ledger.sh state enqueue <feature>
bash .ledger/bin/ledger.sh state set-phase <phase>
bash .ledger/bin/ledger.sh state complete
bash .ledger/bin/ledger.sh state fail-verify
```

诊断长期停滞状态，且不修改文件：

```bash
bash .ledger/bin/ledger.sh check --stale
```

检查 Global Spine Lite 产物：

```bash
bash .ledger/bin/ledger.sh lint-pad .ledger/specs/PAD.md
bash .ledger/bin/ledger.sh lint-architecture .ledger/core/architecture.md
bash .ledger/bin/ledger.sh lint-pid --all
```

如果项目采用 Ledger 的 release 层，并维护 `VERSION` 与 `CHANGELOG.md`：

```bash
bash .ledger/bin/ledger-release-check.sh
```

---

## 7. 发布纪律

Ledger 不要求每次文档或规则编辑都更新版本。

只有具备明确发布价值的一组变更才发版：
- `PATCH`：已有行为、文档、模板或检查的修整
- `MINOR`：完整新能力
- `MAJOR`：不兼容协议或状态机变化

发布说明来自 `CHANGELOG.md`。

---

## 8. 进一步参考

- 概念说明：[Global Spine Lite](./docs/concepts/global-spine-lite.md)。
- 概念说明：[Design Attachments Lite](./docs/concepts/design-attachments-lite.md)。
- 既有项目采用方式：[Adopt Global Spine Lite](./docs/migration/adopt-global-spine-lite.md)。
- 可运行示例流程见 [examples](./examples/)。
- 核心流程参考见 [.ledger/core/workflow.md](./.ledger/core/workflow.md)。
