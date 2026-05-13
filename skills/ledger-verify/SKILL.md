---
name: ledger-verify
description: Use when phase=build-complete. Performs adversarial verification using subagent-driven development: dispatches one subagent per FC for real runtime verification, then reviews evidence quality. Verdict must be based on real command output.
---

# Ledger Verify — 对抗性验证

## Overview

主动尝试打破当前实现。对每个 FC 条目派发独立 subagent 进行真实运行验证，然后审查证据质量。

**Core principle:** 没有真实运行输出就不能说"通过"。推测性语言是禁止的。

## Entry Gate

```bash
bash .ledger/bin/ledger.sh guard verify
```

guard 失败则停止。

## Step 0: 意图覆盖率检查

若 `.ledger/specs/intent.md` 存在：
- 读取意图记录的"关键环节"表
- 对照 Contract 的 FC 条目，检查"必须"环节是否有对应 FC
- 遗漏则输出：`⚠️ 意图覆盖缺口：[R2] 无对应 FC`
- 等待人工确认

无意图记录时跳过。

## Step 1: 列出 FC 关键路径 + 独立性分析

读取 contract，逐条列出所有 FC 条目。

分析 FC 之间的依赖关系：
- **独立 FC**：不依赖其他 FC 的输出或状态，可以并行 verify
- **依赖 FC**：需要其他 FC 的结果作为输入，必须串行

输出分组：
```
并行组 A：FC-01, FC-03, FC-05（独立）
串行链 B：FC-02 → FC-04 → FC-06（FC-04 依赖 FC-02 的输出）
```

## Step 2: 派发 FC Verify Subagent

对每个 FC（或 FC 组），派发一个 verify subagent。

### 并行派发（独立 FC）

对并行组中的每个 FC，同时派发 subagent：

```
Agent("Verify FC-01: [FC 描述]", prompt=verify-fc-prompt)
Agent("Verify FC-03: [FC 描述]", prompt=verify-fc-prompt)
Agent("Verify FC-05: [FC 描述]", prompt=verify-fc-prompt)
```

### 串行派发（依赖 FC）

按依赖顺序逐个派发，前一个完成后再派发下一个。

### Subagent Prompt 构造

使用 `verify-fc-prompt.md` 模板，填入：
- FC 条目全文
- Contract 中的验收标准
- 相关代码文件路径
- 项目测试命令
- PID Card 中的相关上下文

### Subagent 返回格式

每个 subagent 返回：
```
FC-ID: [FC-01]
Verdict: PASS / FAIL / INCONCLUSIVE
Evidence:
  [真实命令输出，前 30 行]
  [...截断，完整输出见终端]
Notes:
  [观察到的行为、边界情况、异常]
```

## Step 3: 汇总 FC 验证结果

收集所有 subagent 返回的结果，汇总为 FC 验证表：

```
| FC | Verdict | Evidence 摘要 | 问题 |
|----|---------|--------------|------|
| FC-01 | PASS | [关键输出] | - |
| FC-02 | FAIL | [失败信息] | [具体问题] |
| FC-03 | PASS | [关键输出] | - |
```

## Step 4: Verify Reviewer

派发一个 verify reviewer subagent，审查所有 FC 验证结果的证据质量。

使用 `verify-reviewer-prompt.md` 模板。

Reviewer 检查：
- 每个 PASS verdict 是否有真实运行输出（不是推测）
- 每个 FAIL verdict 是否准确描述了失败原因
- 是否存在推测性语言（should/expected/theoretically/应该/预期/理论上）
- 证据是否覆盖了 FC 的关键路径和边界情况
- 是否遗漏了 FC 声明的验证项

Reviewer 返回：
```
Approved: Yes / No
Issues:
  - [FC-01] 缺少边界输入 X 的验证
  - [FC-03] 使用了"应该返回"而非实际输出
```

如果 reviewer 发现问题：
- 重新派发对应 FC 的 verify subagent 补充证据
- 重新 review 直到通过

## Step 5: 产品流与状态证据

若 contract 或 PID 声明了 PAD 业务主流程 Step、状态变化、成功后用户去向或体验一致性规则，verify.md 必须记录：

```text
flow-step: [Sx / 辅助 / 管理 / 实验]
user-path: [上游动作 -> 当前动作 -> 下游动作]
状态变化: [运行结果或测试输出]
成功后去向: [运行结果或测试输出]
```

无法自动化验证时，标注为人工验收项。

## Step 6: 设计附件证据

若 PID / contract 引用了设计附件，verify.md 必须记录：

```text
design-evidence: [方案边界的真实输出或验收记录]
sequence-evidence: [调用顺序/状态变化的真实输出或验收记录]
interaction-evidence: [UI状态/反馈规则的真实输出或验收记录]
```

不适用的附件类型可写 `not applicable`。

## Step 7: 运行测试套件

运行 L1 + L2，将测试报告摘要写入 verify.md：
- 通过用例 → 只记录计数：`L1: 23 passed`
- 失败用例 → 保留完整输出

## Step 8: 输出 Verdict

### Verdict 规则

```
verdict = PASS    ← 所有 FC PASS + 测试套件通过 + reviewer approved
verdict = FAIL    ← 任何 FC FAIL 或测试套件失败
verdict = INCONCLUSIVE ← 任何 FC INCONCLUSIVE 且无法解决
```

### Verdict 行格式（严格）

```
verdict = PASS
verdict = FAIL
verdict = INCONCLUSIVE
```

### 禁止的语言

verify.md 中不得出现：
- "应该"、"预期"、"理论上"、"理应"
- "should"、"expected"、"theoretically"、"ought to"
- 任何未经真实运行验证的推测性断言

### 处置

- **PASS** → `bash .ledger/bin/ledger.sh state set-phase verify-pass` → 进入 ledger-ship
- **FAIL** → 回退 ledger-build
- **INCONCLUSIVE** → 见下方处置协议

保存路径：`.ledger/knowledge/[功能名]-verify.md`

---

## INCONCLUSIVE 处置协议

列明无法运行的具体原因，等待人工选择：

**[A] 补充环境后重新 verify**
→ 解决环境问题，重新执行 verify

**[B] 人工签字确认，强制推进**
→ 在 verify.md 末尾追加：
  `MANUAL OVERRIDE — [日期] — [签字人] — [确认理由]`
→ state.md 更新至 verify-pass

**[C] 暂停当前功能**
→ state.md 阻塞字段填写原因

---

## 完成输出

```
✅ verify 完成：[功能名]
  FC 条目：[N] 个（[P] PASS / [F] FAIL / [I] INCONCLUSIVE）
  Subagent 派发：[N] 次（并行 [P] / 串行 [S]）
  Reviewer：approved / [N] issues fixed
  测试套件：L1 [N] passed / L2 [N] passed
  Verdict: [PASS/FAIL/INCONCLUSIVE]
→ 下一步：/ledger.ship 或回退 /ledger.build
```

---

## Red Flags

| Thought | Reality |
|---------|---------|
| "测试通过了所以 verify PASS" | verify 不只是跑测试，是对抗性验证 |
| "这个 FC 应该没问题" | "应该"是禁止语言。跑一遍。 |
| "手动验证过就够了" | 手动验证 ≠ 有记录的验证。写进 verify.md。 |
| "边界情况太难构造" | 难构造 ≠ 不需要。至少尝试。 |
| "所有 FC 都 PASS 了" | 检查有没有推测性语言混入。 |
| "Reviewer 太严格了" | Reviewer 的严格是 verify 的质量保证。 |
