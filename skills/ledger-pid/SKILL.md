---
name: ledger-pid
description: Use when a new feature is requested and no active unshipped feature exists. Defines feature intent, maps to product spine, detects risk boundaries, and generates PID Card. This is constrained intent capture, not open brainstorming.
---

# Ledger PID — 功能意图定义

## Overview

根据开发者描述，生成当前功能的 PID Card，执行边界检测。

**这不是 brainstorming。** PID 是受约束的意图固化：明确做什么、为什么做、属于哪个业务流程、影响什么。

## Entry Gate

```bash
bash .ledger/bin/ledger.sh guard pid
```

guard 失败则停止。

## Step 1: 边界检测

读取 `.ledger/scope/boundaries.md`，对照当前功能描述逐条检查：

**高风险边界（B-H）— 命中则强制暂停：**
输出：`⚠️ 高风险边界：[条目]`
等待人工决策后才能继续。

**中风险边界（B-M）— 命中则附加提示：**
输出：`📋 中风险提示：[条目] — 建议在 contract 阶段明确处理方式`
可继续执行。

## Step 2: FDG 依赖检查（若 specs/FDG.md 存在）

- 确认上游依赖是否已完成（状态 = shipped）
- 从"共享契约"表中筛出适用于当前功能的 SC 条目

## Step 3: Product Spine 映射

读取 `.ledger/specs/PAD.md` 中的产品目标、核心业务主流程、功能类型定义和体验一致性规则。

若 PAD.md 缺少核心业务主流程：
```
⚠️ Product Spine 不完整：PAD.md 缺少核心业务主流程。
[A] 暂停，先补齐 PAD.md
[B] 继续，但在 PID 中标记"流程未知"风险
```

为当前功能填写：
- PAD 业务主流程 Step
- 功能类型：主流程 / 辅助 / 管理 / 实验
- 上游用户动作
- 下游用户动作
- 成功后用户去向

若功能无法映射到业务主流程：
```
⚠️ 主流程映射缺失。
[A] 更新 PAD 业务主流程
[B] 标记为辅助/管理/实验功能，说明服务哪个主流程 step
[C] 暂不做
```

## Step 4: 架构影响预判

读取 `.ledger/core/architecture.md`，填写：
- 涉及模块
- 涉及实体
- 涉及状态机
- 是否改变权限判断
- 是否需要 ADR

## Step 5: 设计附件触发判断

检查是否命中触发条件（design brief / sequence / interaction），命中时生成附件草稿到 `.ledger/design/`。

## Step 6: 功能粒度检查

读取 constitution.md 的功能粒度判定标准。命中大功能条件时生成执行计划草稿。

## Step 7: 生成 PID Card

参照 `.ledger/templates/pid-card.md`，输出至 `.ledger/specs/[功能名]-pid.md`

更新 state.md：
```bash
bash .ledger/bin/ledger.sh state set-phase pid
```

## 完成输出

```
✅ PID Card 生成：[功能名]
  边界检测：[B-H: N 个 / B-M: N 个]
  主流程映射：[Step X / 辅助 / 管理 / 实验]
  架构影响：[涉及 N 个模块 / N 个实体]
  设计附件：[需要 / 不需要]
→ 下一步：/ledger.contract 或加载 ledger:ledger-contract skill
```
