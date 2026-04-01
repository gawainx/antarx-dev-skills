---
name: design-plan-doc-writer
description: 需求澄清完成后，用于产出仓库对齐的设计文档与分阶段开发计划。适用于用户明确要求撰写设计文档、开发计划或二者同时产出时。必须遵循“需求澄清 -> 设计文档 -> 开发计划”的顺序。
---

# 设计与计划文档编写

仅在需求边界、约束与范围已稳定时撰写文档。

## 强制顺序
1. 需求澄清
2. 设计文档
3. 开发计划

## 工作流
1. 先确认需求澄清已完成；未完成则继续澄清。
2. 检查仓库 `docs/design-docs/`、`docs/exec-plans/active/`、`docs/exec-plans/completed/` 与相关代码上下文。
3. 根据功能领域推断文档分类。
4. 检查是否存在同前缀文档。
5. 若存在，先比较范围/日期/内容，并询问“追加还是覆盖”。
6. 先写设计文档，默认落盘到 `docs/design-docs/`。
7. 再写开发计划，默认落盘到 `docs/exec-plans/active/`，并在 `## Related Design Doc` 引用设计文档。
8. 严控范围，明确 In Scope / Out of Scope。

## 输出规则
- 语言跟随用户；默认简体中文。
- 文件命名使用 `{Feat}_{YYYYMMDD}.md`。
- 设计文档默认存放在 `docs/design-docs/`；开发计划默认存放在 `docs/exec-plans/active/`。
- 开发计划结束后，若用户确认完成，移动到 `docs/exec-plans/completed/`。
- 同一需求的设计文档与开发计划文件名必须严格相同（同 basename）。
- 计划任务状态统一：`Designed | Coding | Testing | Finished`。
- 计划仅覆盖本轮已确认范围，不得静默扩 scope。

## 设计文档结构
1. 文件名作为标题
2. `## 核心功能（WHAT）`
3. `### 需求背景（WHY）`
4. `### 需求目标（GOAL）`
5. `### 范围边界`
6. `## 实现流程（HOW）`
7. `## i18n` （如果不涉及则略过）
8. `## 测试用例`

### 设计要求
- 说明当前架构与最终技术决策。
- 明确触点、状态归属、关键约束等信息；
- 如果涉及 UI 场景，需写清布局结构、工具栏归属、宽度策略、空态与稳定性策略。
- 如果涉及国际化，`i18n` 需包含 key、占位符、语言映射、回退策略、影响面。
- 测试分编译检查、手工检查、回归检查。

## 开发计划结构
1. 文件名作为标题
2. `## Related Design Doc`
3. `## Stage`
4. `### Tasks`

### 计划任务模板
计划任务必须包含如下内容：

- `## Stage #N: [阶段名]`
- `### Task #N: [任务名]`
- `**Status:** Designed | Coding | Testing | Finished`
- `**Files:** Create/Modify/Verify` 记录修改的文件
- Function / Implementation Notes / Expected Verification Result： 每个任务记录函数、实现功能、预期结果

### 计划要求
- 至少 1 个阶段，每阶段至少 1 个任务。
- 每个任务必须可验证，建议 15-90 分钟颗粒度。
- 风险驱动验证：高风险变更要求更强自动化或迁移校验。
- 增加最终整体验证任务（build/regression + 计划状态回写）。
- 完成每个Stage后进行 1 次原子提交。

## 旧文档处理
- 无同前缀：直接创建。
- 有同前缀：必须先比较，再询问追加或覆盖，禁止静默覆盖。

## 参考
- 参考 `references/framework.md`。
- 参考 `assets/` 中样例文档风格。
