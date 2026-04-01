---
name: init-project-bootstrap
description: 当用户提及“初始化目录”“初始化项目结构”“初始化项目文档路径”或明确要求执行 `/init` 命令时触发。用于在当前项目目录按标准结构创建 AGENTS.md、ARCHITECTURE.md 与 docs 分层目录及基础文档；若目标文件或目录已存在则直接跳过，严禁覆盖已有内容。
---

# 项目初始化目录结构

按以下步骤执行，确保可重复执行且不会破坏已有文件。

## 执行目标

- 在当前项目根目录创建以下结构（缺失才创建）：
  - `AGENTS.md`
  - `ARCHITECTURE.md`
  - `docs/design-docs/index.md`
  - `docs/design-docs/core-beliefs.md`
  - `docs/exec-plans/active/`
  - `docs/exec-plans/completed/`
  - `docs/exec-plans/tech-debt-tracker.md`
  - `docs/generated/`
  - `docs/product-specs/index.md`
  - `docs/references/`
  - `docs/DESIGN.md`
  - `docs/FRONTEND.md`
  - `docs/PROGRESS.md`
  - `docs/PRODUCT_SENSE.md`
  - `docs/QUALITY_SCORE.md`
  - `docs/RELIABILITY.md`
  - `docs/SECURITY.md`

## 执行步骤

1. 读取并确认当前工作目录（项目根目录）。
2. 运行 `scripts/init_project_structure.sh` 创建目录与文件。
3. 脚本内必须遵守：
   - 目录：使用 `mkdir -p`，天然幂等。
   - 文件：仅在文件不存在时写入最小模板；若已存在则打印 `SKIP` 并保持原内容不变。
   - 禁止删除、重命名、覆盖现有文件。
4. 执行 `AGENTS.md 内容写入` 章节
5. 执行后输出简要结果：
   - 新建了哪些目录/文件
   - 跳过了哪些已存在项

### AGENTS.md 内容写入

将如下内容追加写入到项目目录的 `AGENTS.md` 文件

```markdown
## 文档系统说明

不同目录和文件的职责规则如下：
- AGENTS.md 记录文档阅读顺序、产物落点、禁止事项和关键入口。
- ARCHITECTURE.md 描述系统全局结构、模块边界、依赖方向和不变量。
- docs/design-docs/ 存放设计决策、设计理念和子系统方案；index.md 负责索引；`core-beliefs.md` 负责记录设计文档的使用原则，
- docs/product-specs/ 存放功能规格、用户流程、验收标准；index.md 负责索引。
- docs/exec-plans/active/ 存放进行中的执行计划。
- docs/exec-plans/completed/ 存放已完成执行计划。
- docs/exec-plans/tech-debt-tracker.md 记录项目的技术摘
- docs/references/ 存放外部依赖、协议、框架和工具参考资料摘要。
- docs/generated/ 存放自动生成文档；默认只读，不手工维护。
- `docs/references/` 记录参考资料，包括脚手架、规范代码等
- `docs/DESIGN.md` 记录项目的设计规则，包括UI设计、功能设计规范
- `docs/FRONTEND.md` 记录项目的前端设计架构
- `docs/PROGRESS.md` 项目进度文件，记录项目进度，完成每个开发计划之后，更新本文件
- `docs/PRODUCT_SENSE.md`
- `docs/QUALITY_SCORE.md`
- `docs/RELIABILITY.md` 记录项目的可靠性设计
- `docs/SECURITY.md` 记录项目安全规范

阅读规则：
- 开始任何任务时先读 AGENTS.md。
- 涉及结构、分层、依赖、模块边界时读 ARCHITECTURE.md 和相关 design docs。
- 涉及功能目标、用户流程、验收条件时读 product-specs。
- 涉及中大改动时先在 exec-plans/active/ 创建或更新执行计划，再开始实施。
- 涉及外部依赖、框架、协议时先读 references。
- 涉及生成物时只读 generated，不手工修改 generated 下的内容。

写回规则：
- 需求澄清和功能范围写入 docs/product-specs/。
- 技术设计和方案决策写入 docs/design-docs/。
- 中大任务的计划、阶段进度、决策日志写入 docs/exec-plans/active/。
- 完成后的执行计划移入 docs/exec-plans/completed/。
- 开发计划完成后使用 `completion-progress-recorder`技能更新 `docs/PROGRESS.md`
- 遗留问题和明确未解决事项写入 tech-debt-tracker.md。
- 工具或脚本生成的摘要写入 docs/generated/。

```

## 约束

- 仅在用户明确要求初始化目录结构时执行。
- 任何情况下都不覆盖已存在文件内容。
- 若遇到权限问题或路径异常，停止写入并反馈错误。

