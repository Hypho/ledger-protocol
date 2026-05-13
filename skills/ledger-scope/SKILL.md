---
name: ledger-scope
description: Use before the first feature or when product direction changes. Assesses Ledger applicability, identifies risk boundaries, and optionally generates feature dependency graph.
---

# Ledger Scope — 适用性与风险边界评估

## Overview

评估 Ledger 是否适合当前项目，识别风险边界，可选生成功能依赖图。

这不是 brainstorming。这是 applicability assessment。

## Step 1: 项目特征评估

检查：
- 项目是否有明确产品目标？
- 是否有可识别的用户角色？
- 是否有核心业务流程？
- 项目复杂度是否需要 Ledger？

输出评估结果：Ledger-only / Ledger + specialist review / Do not use Ledger alone

## Step 2: 风险边界扫描

读取 `.ledger/scope/boundaries.md`，评估项目整体风险特征。

输出风险档案。

## Step 3: Product Spine readiness

检查 PAD.md 是否已具备：
- 产品目标
- 核心业务主流程
- 功能类型定义
- 体验一致性规则

缺失时提示补齐。

## Step 4: Architecture Spine readiness

检查 architecture.md 是否已具备：
- 模块边界
- 核心实体归属
- 依赖方向
- ADR 触发条件

缺失时提示补齐。

## Step 5: 功能依赖图（可选）

若开发者有多个待开发功能，可选生成功能依赖图（FDG）。

## 完成输出

```
✅ Scope 评估完成
  Ledger 适用性：[Ledger-only / Ledger+specialist / 不建议]
  风险边界：[B-H: N 个 / B-M: N 个]
  Product Spine：[就绪 / 需补齐]
  Architecture Spine：[就绪 / 需补齐]
  FDG：[已生成 / 跳过]
```
