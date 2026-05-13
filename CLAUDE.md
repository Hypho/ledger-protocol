# [项目名] — Ledger 工作空间
> Ledger — Auditable AI-Assisted Development Protocol v0.1.0

---

## 0. Skills 系统

Ledger 2.x 引入 skills 系统。每个功能阶段有对应的 skill，slash commands 是 skill 的快捷入口。

**SessionStart hook** 会在新会话时自动检测 `.ledger/` 并注入 `using-ledger` skill。Agent 看到后应：
1. 读取 state.md 识别当前 phase
2. 根据 phase 加载对应 skill（使用 Skill 工具）
3. 进入阶段前运行 guard

可用 skills：`using-ledger` / `ledger-scope` / `ledger-pid` / `ledger-contract` / `ledger-build` / `ledger-verify` / `ledger-ship` / `ledger-retro`

---

## 1. 启动序列

> 入口职责：`CLAUDE.md` 是 Claude Code 热层入口。
> 若流程事实上不一致，以 `.ledger/core/workflow.md` 为准。
> 若硬约束上不一致，以 `.ledger/core/constitution.md` 为准。

每次新会话，按以下顺序执行，不跳过：

```
Step 0  初始化检测：
          读取 constitution.md 产品名称字段
          若名称字段 = "[由 /ledger.init 填写]"：
            输出 "⚠️ 项目尚未初始化，请先执行 /ledger.init"
            停止，不执行后续步骤，不响应功能命令

Step 1  读取 state.md，获取当前功能名和阶段

Step 2  文件存在性校验（根据阶段）：
          阶段 = pid                      → 检查 .ledger/specs/[功能名]-pid.md 是否存在
          阶段 = contract / build / build-complete → 检查 .ledger/contracts/[功能名].md 是否存在
          阶段 = verify-pass              → 检查 .ledger/knowledge/[功能名]-verify.md 是否存在
                                            且内容包含 "verdict = PASS" 或 "MANUAL OVERRIDE"
        校验失败：输出 "⚠️ 状态不一致：state.md 声明 [阶段] 但对应文件缺失或不匹配"
                  等待人工修正，不继续执行任何命令

Step 3  校验通过后输出：当前任务理解（一句话）+ 发现的约束冲突风险

Step 4  等待人工确认后再执行
```

> **⚠️ Session Memory 说明**
> Claude Code 在后台维护自身的 session_memory（持久化会话摘要）。
> 当 session_memory 与 state.md 内容冲突时，**以 state.md 为准**。
> state.md 是 Ledger 的唯一状态事实来源，任何时候有疑问都重新读取该文件。

---

## 2. 执行模式

```
每个功能：/ledger.pid → /ledger.contract → /ledger.build → /ledger.verify → /ledger.ship
每 3-5 个功能：/ledger.retro
```

> **⚠️ Guard 强制执行**
> 进入任何阶段前，必须先执行对应 guard 命令。guard 失败则停止，不得绕过。
> 即使你认为状态正确，也必须运行 guard。不运行 guard 直接进入阶段 = 违规。
>
> ```bash
> bash .ledger/bin/ledger.sh guard pid
> bash .ledger/bin/ledger.sh guard contract
> bash .ledger/bin/ledger.sh guard build
> bash .ledger/bin/ledger.sh guard verify
> bash .ledger/bin/ledger.sh guard ship
> ```

> 流程定义源见 `.ledger/core/workflow.md`。本文件只保留热层摘要，避免多处定义漂移。

> **⚠️ Git Commit 原则**
> 一个 commit = 一个独立可回滚的变更。不得将多个无关修复合并为一个 commit。
> 每个 commit 必须能独立 revert 而不影响其他改动。
> commit message 格式：`fix: / feat: / docs: / refactor:` + 一句话说明改了什么、为什么改。

---

## 3. 命令清单

| 命令 | 触发时机 | 加载 Skill |
|------|---------|-----------|
| `/ledger.init` | 项目开始（一次性） | 无（直接执行） |
| `/ledger.scope` | 首次功能前建议执行 | `ledger:ledger-scope` |
| `/ledger.pid` | 每个功能开始 | `ledger:ledger-pid` |
| `/ledger.contract` | pid 完成后 | `ledger:ledger-contract` |
| `/ledger.build` | contract 完成后 | `ledger:ledger-build` |
| `/ledger.verify` | build 完成后 | `ledger:ledger-verify` |
| `/ledger.ship` | verify PASS 后 | `ledger:ledger-ship` |
| `/ledger.retro` | 每 3-5 个功能 | `ledger:ledger-retro` |

Slash commands 是 skill 的快捷入口。Agent 也可以通过 Skill 工具直接加载对应 skill。

---

## 4. 文件读取装配规则

> 控制 context 加载边界。非列表内的文件不主动读取。
> **本节是各命令文件读取的唯一来源。命令文件内部不再重复声明，避免双写漂移。**

**常驻层**（每次会话启动必读）
```
CLAUDE.md              — 当前文件
.ledger/state.md         — 当前进度与阻塞
```

**命令触发层**（进入对应命令时读取）
```
/ledger.init      → .ledger/templates/PAD.md
                  .ledger/templates/intent.md
/ledger.scope     → .ledger/scope/boundaries.md
                  .ledger/core/constitution.md
/ledger.pid       → .ledger/scope/boundaries.md
                  .ledger/specs/PAD.md（Product Spine：业务主流程 / 功能类型）
                  .ledger/core/architecture.md（Architecture Spine：模块 / 实体 / ADR 触发条件）
                  若 specs/FDG.md 已存在 → .ledger/specs/FDG.md
                  若 specs/intent.md 已存在 → .ledger/specs/intent.md（意图回溯检查）
/ledger.contract  → .ledger/templates/contract.md
                  .ledger/specs/[当前功能]-pid.md
                  .ledger/specs/PAD.md（若存在）
/ledger.build     → .ledger/core/constitution.md
                  .ledger/core/architecture.md（涉及模块、实体、状态机、权限或依赖时）
                  .ledger/contracts/[当前功能].md
                  .ledger/specs/[当前功能]-pid.md
                  .ledger/specs/PAD.md（若存在）
                  .ledger/contracts/archive/（跨功能一致性扫描用）
/ledger.verify    → .ledger/contracts/[当前功能].md
                  若 specs/intent.md 已存在 → .ledger/specs/intent.md（意图覆盖率检查）
/ledger.ship      → .ledger/core/constitution.md
/ledger.retro     → .ledger/specs/PAD.md
                  .ledger/specs/FDG.md（若存在）
                  .ledger/knowledge/tech-debt.md
                  .ledger/contracts/archive/（所有已完成契约）
                  若 specs/intent.md 已存在 → .ledger/specs/intent.md（意图记录复查）
```

**按需层**（有明确需要时才读，不默认加载）
```
.ledger/core/architecture.md       — 涉及新模块、新实体、状态机、权限、依赖或 ADR 触发条件时
.ledger/core/workflow.md           — 需要核对完整流程、阶段输入输出或停止条件时
.ledger/knowledge/decisions/       — 遇到历史决策冲突时
.ledger/knowledge/errors/          — 调查重复失败模式时
.ledger/exec-plans/active/         — 跨会话大功能时
.ledger/templates/IFD.md           — 前端交互功能的 pid 阶段
```

---

## 5. 硬约束

> 完整约束见 `.ledger/core/constitution.md`。
> 若此处内容为 `[由 /ledger.init Step 2 填写]`，说明项目尚未初始化，请先执行 `/ledger.init`。

[由 /ledger.init Step 2 填写]

---

## 6. 开源维护规则

若当前项目采用 Ledger release layer 维护版本与发布记录，完整规则见 constitution.md §16。

---

## 7. 框架边界（不覆盖）

- 代码性能质量（高并发、慢查询）
- 安全漏洞（鉴权遗漏、注入攻击）
- 生产部署、监控、告警
- 事务一致性和并发竞态
