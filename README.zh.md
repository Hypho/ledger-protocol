# Ledger — 面向 AI 辅助开发的可审计协议框架
> 面向人机协作开发的轻量协议框架 | v0.1.0
> English: [README.md](./README.md)

[![Ledger Check](https://github.com/Hypho/ledger-protocol/actions/workflows/ledger-check.yml/badge.svg)](https://github.com/Hypho/ledger-protocol/actions/workflows/ledger-check.yml)

---

## 是什么

Ledger 是一套面向 AI 辅助软件开发的轻量协议框架，用来把产品意图、实现范围和验证证据显式化。

它把开放式的 AI 对话，收束成一条可追踪的工作流：先定义意图，再写行为契约，然后按契约实现，用真实运行结果验证，最后归档变更。

Ledger 保持日常功能闭环轻量，但用两个全局主干约束功能：`PAD.md` 中的 Product Spine（产品主干）和 `architecture.md` 中的 Architecture Spine（架构主干）。功能进入 build 前，应说明自己位于哪条核心业务流程、触碰哪些模块和实体边界。

Ledger 适合产品型开发者、独立开发者和小团队：既希望借助 AI 提速，又不想丢掉对范围、状态和质量的控制。

它不是代码生成器，不是 agent 调度系统，也不是 CI/CD 的替代品。它更像一层协议：让人的决策和 AI 的执行始终对齐。

核心思路：**实现之前先定义行为，发布之前先验证行为。**

---

## Skills 系统

Ledger 2.x 采用 skills 架构。Skills 是可组合的协议文档，引导 Agent 完成每个阶段，根据项目状态自动触发。

| Skill | 阶段 | 用途 |
|-------|------|------|
| `using-ledger` | 会话启动 | 状态感知、阶段路由、guard 强制执行 |
| `ledger-scope` | 功能前 | Ledger 适用性评估 |
| `ledger-pid` | pid | 意图定义 + 边界检测 |
| `ledger-contract` | contract | 行为契约生成 |
| `ledger-build` | build | TDD 实现 + 复杂度评分 |
| `ledger-verify` | verify | 子 Agent 驱动的对抗性验证 |
| `ledger-ship` | ship | 测试、验收、归档 |
| `ledger-retro` | 每 3-5 个功能 | 协议质量复盘 |

**工作原理：**
- SessionStart hook 检测项目中的 `.ledger/` 目录，将 `using-ledger` 注入 Agent 上下文
- Agent 读取 `state.md` 确定当前阶段
- 匹配的 skill 自动加载或通过 Skill 工具加载
- Guard 在执行前强制检查阶段入口条件

Claude Code 中 skill 通过 plugin 提供。

---

## 什么时候适合用 Ledger

适合使用 Ledger 的情况：

- 你正在借助 AI 开发产品，并且希望过程可追踪、可审计。
- 你希望产品意图、实现、验证和发布之间有清晰交接。
- 你是独立开发者、产品型开发者，或按功能推进的小团队。
- 你更相信明确契约和检查点，而不是依赖一段越来越长的 prompt。

不适合只靠 Ledger 解决的情况：

- 你需要的是通用任务管理器或多 agent 调度系统。
- 你需要的是部署、监控、事故响应或 CI/CD 编排。
- 你正在处理高风险安全、金融、并发或性能问题，但没有专项审查。

---

## 适用边界

采用前请先判断项目是否落在 Ledger 的适用范围内。

### 框架识别但不求解（强制暂停，等待外部专项处理）

- **事务一致性与并发竞态** — boundaries B-H02 / B-H05
- **金融操作与敏感数据** — boundaries B-H03 / B-H06
- **跨用户聚合 / 实时通信** — boundaries B-H01 / B-H04
- **代码性能（N+1、慢查询等）** — `/ledger.build` 运行时边界扫描

> 这些场景 Ledger 会主动拦住你，但不提供解决方案。需配合专项审查（安全 / 性能 / DBA）使用。
> 识别 + 暂停本身就是框架的交付物之一。

### 框架完全不涉足

- **生产部署、监控、告警**
- **多人并发开发的冲突协调**
- **CI/CD 流水线与发布管理**

> 这些场景 Ledger 完全不介入，需要其他工具链协同。

---

## 快速开始

安装说明：[INSTALL.zh.md](./INSTALL.zh.md)
完整使用指南：[USAGE.zh.md](./USAGE.zh.md)
Global Spine Lite 说明：[docs/concepts/global-spine-lite.md](./docs/concepts/global-spine-lite.md)
Design Attachments Lite 说明：[docs/concepts/design-attachments-lite.md](./docs/concepts/design-attachments-lite.md)
既有项目采用方式：[docs/migration/adopt-global-spine-lite.md](./docs/migration/adopt-global-spine-lite.md)

```bash
# 推荐：从 GitHub 直接安装到项目目录
curl -fsSL https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.sh | bash -s -- --target your-project --mode auto

# Windows PowerShell：安装到当前目录
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Hypho/ledger-protocol/main/scripts/install-from-github.ps1 | iex"

# 从已克隆的 Ledger 仓库安装
bash scripts/install-ledger.sh --target your-project --mode auto

# 在 Claude Code 中执行
/ledger.init    # 项目初始化（一次性）
/ledger.scope   # 适用性与风险边界评估（首次功能前建议执行）

# 可选：已安装项目自检
cd your-project
bash .ledger/bin/ledger.sh check --project

# 框架维护者：发布检查见 RELEASE.md
```

远程安装器会直接把 Ledger 文件复制到目标项目目录。运行时检查仍需要 `bash` 环境。

### Claude Code Plugin 安装（推荐）

Ledger 可作为 Claude Code plugin 安装：

```bash
# 注册 Ledger marketplace
claude plugin marketplace add https://github.com/Hypho/ledger-protocol

# 安装 plugin
claude plugin install ledger@ledger
```

安装后，当项目存在 `.ledger/` 时，Ledger skills 会在会话启动时自动注入。

---

## 工具支持

Ledger 的协议层不绑定具体工具，每个工具使用各自的原生指令和 skill 机制。

| 工具 | 支持程度 | 机制 | 入口 |
|------|---------|------|------|
| Claude Code | 一等支持 | Plugin + skills + SessionStart hook | [docs/adapters/claude-code.md](./docs/adapters/claude-code.md) |

`CLAUDE.md` 是 Claude Code 运行入口。流程事实和硬约束仍分别以 `.ledger/core/workflow.md` 与 `.ledger/core/constitution.md` 为准。

Claude Code 用户可通过 plugin 安装实现 skill 自动注入。

---

## 示例

查看 [examples](./examples/) 中的可运行已完成功能流程：

- [todo-feature](./examples/todo-feature/) 展示最小可用流程，包含校验和保存失败处理。
- [secure-notes](./examples/secure-notes/) 展示更接近真实业务的所有权边界、跨用户拒绝访问和验证证据。
- [order-flow](./examples/order-flow/) 展示 Global Spine Lite：PAD 业务主流程、架构边界、PID 主流程映射，以及 verify 中的产品流证据。

---

## 执行模式

每个功能的流程：`pid → contract → build → verify → ship`

每 3-5 个功能执行一次：`retro`

权威流程定义见 [.ledger/core/workflow.md](./.ledger/core/workflow.md)。README、适配文档和命令文件只应摘要该文件，不应重新定义另一套流程。

---

## 命令清单

| 命令 | 触发时机 | Skill | 职责 |
|------|---------|-------|------|
| `/ledger.init` | 项目开始（一次性） | — | 交互式初始化，生成 constitution / PAD 初稿 / state |
| `/ledger.scope` | 首次功能前建议执行 | `ledger:ledger-scope` | Ledger 适用性与风险边界评估 |
| `/ledger.pid` | 每个功能开始 | `ledger:ledger-pid` | 定义功能意图，执行边界检测，生成 PID Card |
| `/ledger.contract` | pid 完成后 | `ledger:ledger-contract` | 生成行为契约（FC/NF 条目），作为 build 和 verify 的基准 |
| `/ledger.build` | contract 完成后 | `ledger:ledger-build` | TDD 顺序实现 + 复杂度评分 |
| `/ledger.verify` | build 完成后 | `ledger:ledger-verify` | 子 Agent 驱动的对抗性验证，基于真实运行结果出 verdict |
| `/ledger.ship` | verify PASS 后 | `ledger:ledger-ship` | 冒烟测试，登记已完成功能，归档 contract |
| `/ledger.retro` | 每 3-5 个功能 | `ledger:ledger-retro` | 回顾 contract 质量，清理技术债 |

---

## 目录结构

```
your-project/
├── CLAUDE.md                        ← 热层，会话启动自动加载
│                                      包含：启动序列 / 执行模式 / 命令清单 / 文件装配规则
├── .claude/
│   └── commands/                    ← 8 个命令文件（各命令协议定义）
│       ├── ledger.init.md
│       ├── ledger.scope.md
│       ├── ledger.pid.md
│       ├── ledger.contract.md
│       ├── ledger.build.md
│       ├── ledger.ship.md
│       ├── ledger.verify.md
│       └── ledger.retro.md
└── .ledger/
    ├── state.md                     ← 热层，跨会话状态机
    ├── core/
    │   ├── constitution.md          ← 温层：项目宪法，硬约束 + 文件命名规范
    │   └── architecture.md          ← 冷层：按需加载
    ├── schemas/
    │   ├── state.schema.json        ← 未来结构化状态源的草案 schema
    │   └── queue.schema.json        ← 未来结构化队列草案，v1.x 不启用
    ├── state.example.json           ← 示例文件，不作为运行时状态源
    ├── queue.example.json           ← 示例文件，不作为运行时状态源
    ├── scope/
    │   ├── boundaries.md            ← 边界特征清单（B-H / B-M 风险规则）
    │   └── fitness.md               ← 适配评估结果（/ledger.scope 生成）
    ├── specs/                       ← 项目实例文件（由命令生成，非空白模板）
    │   ├── PAD.md                   ← 产品结构文档（/ledger.init 生成初稿）
    │   ├── FDG.md                   ← 可选功能依赖图（/ledger.scope，明确选择后生成）
    │   └── [功能名]-pid.md          ← 各功能 PID Card（/ledger.pid 生成）
    ├── contracts/                   ← 行为契约
    │   ├── [功能名].md              ← 进行中功能的 contract
    │   └── archive/                 ← 已完成功能的 contract（/ledger.ship 归档）
    ├── templates/                   ← 空白参照模板（不直接填写）
    │   ├── PAD.md / FDG.md / IFD.md
    │   ├── pid-card.md / contract.md / verify.md
    │   ├── exec-plan.md / handover.md
    │   └── README.md                ← 模板目录说明
    ├── hooks/
    │   └── check-state.sh           ← SessionStart Hook（校验 state.md 与文件系统一致性）
    ├── exec-plans/
    │   ├── active/                  ← 执行中的大功能计划
    │   └── completed/
    ├── knowledge/
    │   ├── [功能名]-verify.md       ← verify 记录（verdict + 对抗测试结果）
    │   ├── tech-debt.md             ← 技术债追踪
    │   ├── decisions/               ← 架构决策归档
    │   ├── errors/                  ← 失败记录
    │   ├── handover/
    │   └── archive/                 ← state / 已完成功能的历史归档
    └── tests/
        ├── features/
        ├── fixtures/
        └── api/
```

### Plugin 结构（独立安装）

Ledger plugin 提供 skills 和 hooks，通过 `claude plugin install` 安装，存放在 Claude Code plugin 缓存中，不在项目目录内：

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

项目目录只包含数据层（`.ledger/`）和入口文件（`CLAUDE.md`）。Plugin 提供运行时引导。

---

## 关键机制

### 文件命名规范
所有 contract / verify / exec-plan / pid-card 文件路径都基于 state.md 的功能名字段生成，命名规则在 constitution.md 中定义。启动校验会对比 state.md 声明的阶段与对应文件是否存在，不一致时停止执行。

### Global Spine Lite

Ledger 在不增加日常流程步骤的前提下增加全局约束：

- `PAD.md` 是 Product Spine：产品目标、目标用户与场景、核心业务主流程、核心实体与状态、体验一致性规则、功能类型定义。
- `architecture.md` 是 Architecture Spine：架构原则、模块边界、实体归属、状态机归属、权限判断位置、数据写入边界、依赖方向、ADR 触发条件。
- PID Card 必须将功能映射到 PAD 的业务主流程 Step，或明确标记为辅助 / 管理 / 实验功能。
- Build 阶段在功能触碰模块、实体、状态机、权限或依赖时，对照 Architecture Spine 做一致性检查。

这不是 PRD 系统，也不是架构治理平台，而是给现有 `pid -> contract -> build -> verify -> ship` 闭环增加一层轻量全局约束。

### 状态源
在 v1.x 阶段，`.ledger/state.md` 仍然是人类可读的状态真相源。Ledger 同时提供 `.ledger/schemas/state.schema.json` 草案，用于定义未来结构化 state 的形状，但它不会改变当前运行方式。

Ledger 还提供仅用于预研的结构化示例：`.ledger/state.example.json`、`.ledger/schemas/queue.schema.json` 与 `.ledger/queue.example.json`。这些文件在 v1.x 不作为运行时真相源。

工具需要执行的状态变更应通过受控状态入口完成：

```bash
bash .ledger/bin/ledger.sh state validate
bash .ledger/bin/ledger.sh state enqueue <feature>
bash .ledger/bin/ledger.sh state set-phase <phase>
bash .ledger/bin/ledger.sh state complete
bash .ledger/bin/ledger.sh state fail-verify
```

`ledger-check.sh` 会检查 `state.md` 的基础结构、状态逻辑一致性，并通过 fixture 覆盖常见非法状态。

需要诊断长期停滞或重复失败时，运行：

```bash
bash .ledger/bin/ledger.sh check --stale
```

### Contract / Verify Lint
Ledger 会检查行为契约和验证记录的基础结构：

- contract 必须包含 FC 条目和明确不做范围
- contract 不能保留明显模板占位符
- verify 必须包含且只包含一个严格的 `verdict = PASS|FAIL|INCONCLUSIVE` 行
- verify 禁止使用“应该 / 预期 / 理论上”等推理性语言替代真实输出
- PASS 类型 verify 必须包含 `output:` 或 `command:` 等运行证据标记

### Command Guard
Ledger 提供命令入口检查，用于根据 `state.md` 和必要产物判断某个 `/ledger.*` 命令是否允许开始。

```bash
bash .ledger/bin/ledger-guard.sh pid
bash .ledger/bin/ledger-guard.sh contract
bash .ledger/bin/ledger-guard.sh build
bash .ledger/bin/ledger-guard.sh verify
bash .ledger/bin/ledger-guard.sh ship
```

guard 不执行命令，不生成文件，不修改 state，只报告当前命令是否允许进入。

### Global Spine Lite 检查

```bash
bash .ledger/bin/ledger.sh lint-pad <file>
bash .ledger/bin/ledger.sh lint-architecture <file>
bash .ledger/bin/ledger.sh lint-pid <file|--all>
```

这些是轻量结构检查，不评判产品质量、体验质量或架构优劣。

### Scope Assessment

`/ledger.scope` 用来在功能开发前判断 Ledger 是否适合当前项目，并识别需要人工或专项审查的风险边界。

它输出三种使用模式之一：

- `Ledger-only`
- `Ledger + specialist review`
- `Do not use Ledger alone`

FDG 生成为可选项。只有在开发者明确提供 3 个以上已知功能，并且确实需要依赖规划时才生成。

### 边界检测
`/ledger.pid` 阶段对照 boundaries.md 执行边界检测：

| 类型 | 内容 | 处置 |
|------|------|------|
| 高风险（B-H） | 实时通信 / 并发写入 / 金融操作 / 跨用户聚合 / 多表事务 / 敏感数据 | 强制暂停，等待人工决策 |
| 中风险（B-M） | 复杂权限 / 文件处理 / 第三方集成 / 异步任务 / 复杂查询 / Schema 变更 | 附加提示，可继续 |

大功能门控（跨 3+ 模块 / Schema 变更 / 需 2+ 会话 / 依赖 3+ 未完成功能）→ 强制生成执行计划，人工确认后继续。

### 功能粒度
Ledger 将功能粒度纳入协议约束。一个功能应能完成一次完整的 `contract -> build -> verify -> ship` 闭环。`/ledger.pid` 会提前提示过大功能，复杂度评分模型从四个维度（边界情况、依赖关系、状态转换、跨模块影响）各打 1-3 分，总分决定构建策略：≤8 直接构建，9-12 组件计划，13-16 执行计划，>16 必须拆分。

### 可复用经验
跨功能长期有效的工程知识记录在 `.ledger/knowledge/patterns.md`。`/ledger.ship` 可以把稳定经验沉淀进去，`/ledger.retro` 负责清理过时或只属于单个功能的内容。它不是进度日志，也不替代模块 handover。

### Verify 机制
不是审查代码，而是主动证伪。针对每条 FC 条目构造边界输入，实际运行，截取真实输出，禁止推理性语言。Verdict 三种结果：`PASS` / `FAIL`（回退 build）/ `INCONCLUSIVE`（三选项处置协议）。2.x 中，验证采用子 Agent 驱动开发模式：每个 FC 条目派发独立 subagent 进行对抗性测试，再由 reviewer 审查证据质量。

---

## 版本号规则

采用语义化版本：`MAJOR.MINOR.PATCH`

| 位 | 触发条件 | 典型变更 |
|----|---------|---------|
| **MAJOR** | 协议不兼容变更，已初始化项目无法平滑升级 | 命令增删/重命名；状态机阶段调整；文件命名规范变更；目录结构重组 |
| **MINOR** | 向后兼容的协议扩展 | 新增可选 Step 或检查项；新增模板；新增非强制子协议；Hook 能力增强 |
| **PATCH** | 不新增独立能力的修整或补强 | 措辞/错别字；文档内部一致性修正；职责收窄；模板对齐；已有检查规则微调 |

> 只有具备明确发布价值的变更集合才更新版本号；小改可以先暂留本地或进入普通提交，积累到一定程度再发版。
> 重要里程碑打 git tag（`v1.0.0`、`v1.1.0`、`v2.0.0`）。
> 历史记录保留近 10 条于本表，更早记录移至 `CHANGELOG.md`。

---

## 版本历史

详细发布记录维护在 [CHANGELOG.md](./CHANGELOG.md)。
发布流程说明见 [RELEASE.md](./RELEASE.md)。

| 版本 | 日期 | 核心变更 |
|------|------|---------|
| v0.1.0 | 2026-05-13 | 首次公开发布。Skills 架构、复杂度评分、子 Agent 驱动验证、Claude Code plugin 架构 |
