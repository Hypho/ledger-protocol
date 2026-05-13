---
name: ledger-ship
description: Use when phase=verify-pass and verify record exists with PASS or MANUAL OVERRIDE. Runs full test suite, human acceptance, impact self-check, and archives the feature.
---

# Ledger Ship — 测试、验收、归档

## Overview

完成 Ledger 内部交付闭环：全量测试、人工验收、影响面自查、归档。

## Entry Gate

```bash
bash .ledger/bin/ledger.sh guard ship
```

guard 失败则停止。

`.ledger/knowledge/[功能名]-verify.md` 必须存在，且包含 `verdict = PASS` 或 `MANUAL OVERRIDE`。

## Step 1: 补全测试脚本 TODO

扫描 `.ledger/tests/features/[功能名].*`，检查未填写的 TODO 项。有则提示选择：补全 / 跳过。

## Step 2: 分级执行测试

**L1（单元）→ 自动执行**
**L2（冒烟，核心路径）→ 自动执行**
**L3（完整 E2E + 回归）→ 自动执行**

测试失败时提示选择：修复 / 更新契约 / 标记已知失败。
回归失败时提示选择：修复 / 确认为预期变更。

## Step 3: 人工验收

从契约中筛出自动化未覆盖的条目，输出待验清单。等待人工反馈。

验收失败时：
- 实现不符 → 打回 build
- 契约遗漏 → 补充契约后修复
- 体验问题 → 登记 tech-debt，继续

## Step 4: 影响面自查

逐条检查：
- PAD 实体定义是否变更？
- PAD 业务主流程是否变化？
- 是否产生新的体验一致性规则？
- 是否出现功能堆叠信号？
- architecture.md 是否变更？
- 是否命中 ADR 触发条件？
- 是否有稳定模式可沉淀？
- Schema 是否变更？→ 确认 migration

`knowledge/patterns.md` 只记录跨功能、跨会话有效的模式。

## Step 5: 归档

- 更新 constitution.md 已完成功能列表
- 移动 contract 到 `contracts/archive/`
- 移动 PID Card 到 `knowledge/archive/`
- 记录架构决策到 `knowledge/decisions/`
- Git commit

更新 state.md 已完成表，清空"当前"，填写下一个队列功能。

```bash
bash .ledger/bin/ledger.sh state complete
```

## 完成输出

```
✅ ship 完成：[功能名]
  测试：L1 ✅ L2 ✅ L3 [N/N] | 回归 [N/N]
  验收：[N/N] 通过
  影响面：[无跨功能影响 / 已处理 N 项]

项目进度：已完成 [N] 个功能 | 待开发：[列出]
[如有] → 建议在完成 [N] 个功能后执行 ledger-retro
```
