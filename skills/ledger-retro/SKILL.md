---
name: ledger-retro
description: Use every 3-5 shipped features or when intent drift is suspected. Reviews product drift, feature stacking, architecture violations, and extracts reusable patterns.
---

# Ledger Retro — 意图漂移复盘

## Overview

每 3-5 个功能后的协议质量复盘。不做团队管理复盘，做 Ledger 协议质量复盘。

## Step 1: 产品意图对比

对照 PAD.md 的产品目标、核心业务主流程与实际已完成功能，填写偏差表。

提问：
- 有没有"做出来和当初想要的不一样"的地方？
- 有没有做完才发现不需要的功能？

## Step 2: 产品流与功能堆叠检查

读取最近 3-5 个已完成 PID / contract / verify：
- 是否每个功能都映射到 PAD 核心业务主流程？
- 主流程/辅助/管理/实验功能比例是否合理？
- 是否多个辅助功能推进但核心主流程没完成？
- 是否有重复定义的体验规则？

## Step 3: 流程质量评估

评估 PID 清晰度、契约完整性、build 检查有效性、测试覆盖质量。

根因定位：偏差在哪一层？意图层 / 契约层 / 执行层 / 需求层？

## Step 4: 架构漂移检查

对照 architecture.md 与最近功能实现：
- 是否绕过模块边界？
- 实体写入归属是否清晰？
- 状态机变更是否记录？
- 是否命中 ADR 触发条件但未记录？

## Step 5: 技术债回顾

读取 `knowledge/tech-debt.md` 活跃条目，评估是否需要新登记或调整优先级。

## Step 6: 可复用经验清理

读取 `knowledge/patterns.md`：删除流水账、合并重复、标记过时。

## Step 7: 生成复盘记录

保存至 `knowledge/decisions/[日期]-retro.md`。

## 完成输出

```
✅ 复盘完成
  产品意图：[N] 处偏差
  功能堆叠：[有/无] 风险
  架构漂移：[N] 项需处理
  技术债：[N] 条活跃
  改进行动：[高优先级列表]
```
