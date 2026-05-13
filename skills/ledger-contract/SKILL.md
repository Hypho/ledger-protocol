---
name: ledger-contract
description: Use when phase=pid and PID Card exists. Generates behavior contract from PID Card with FC/NF entries, scope boundaries, and test coverage mapping.
---

# Ledger Contract — 行为契约生成

## Overview

根据 PID Card 生成行为契约文件。

## Entry Gate

```bash
bash .ledger/bin/ledger.sh guard contract
```

guard 失败则停止。

## Pre-checks

**PID Card 存在性：** `.ledger/specs/[功能名]-pid.md` 必须存在。

**PAD 占位符警告：** 若 PAD.md 存在未填写字段，提示选择：继续 / 先完善 PAD。

**PID 主流程映射完整性：** PID 必须包含 PAD 业务主流程 Step、功能类型、成功后用户去向、架构影响、设计附件判断。缺失时提示补齐。

**设计附件读取：** 若 PID 声明需要设计附件，读取附件中的验收映射，转为 FC/NF 候选。

## 契约生成

参照 `.ledger/templates/contract.md`，根据 PID Card 生成：
- **FC 条目**：核心路径 + 边界条件
- **NF 条目**：性能、错误提示、交互反馈等
- **流程约束**：PAD 业务主流程 Step、成功后用户去向、状态变化
- **体验一致性约束**：继承 PAD 中相关的空状态、错误提示、权限不足等规则
- **设计附件约束**：吸收设计附件中的验收映射
- **明确不做**：PID Card 标注的范围外功能

## 粒度检查

使用复杂度评分替代硬性 FC 数量限制：

| 维度 | 低 (1分) | 中 (2分) | 高 (3分) |
|------|----------|----------|----------|
| FC 边界情况总数 | ≤2 | 3-5 | >5 |
| 外部依赖 | 无 | 1-2 | >2 |
| 状态转换数 | ≤2 | 3-5 | >5 |
| 跨模块影响 | 单模块 | 2模块 | >2模块 |

| 总分 | 处理 |
|------|------|
| ≤8 | 正常 contract |
| 9-12 | contract + 标注复杂度较高 |
| 13-16 | 建议生成 exec plan |
| >16 | 必须拆分 |

若任一核心 FC 无法独立验证，必须补充验证方式或拆分功能。

输出路径：`.ledger/contracts/[功能名].md`

## 更新状态

```bash
bash .ledger/bin/ledger.sh state set-phase contract
```

## 完成输出

```
✅ Contract 生成：[功能名]
  FC 条目：[N] 个（正常路径 [N] / 边界 [N] / 次要 [N]）
  NF 条目：[N] 个
  复杂度评分：[N] 分
  明确不做：[N] 项
→ 下一步：/ledger.build 或加载 ledger:ledger-build skill
```
