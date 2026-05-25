---
name: init-project-bootstrap
description: 当用户提及“代码仓初始化”“初始化代码仓”“初始化目录”“初始化项目结构”“初始化项目文档路径”“初始化 Codex 持续开发工作流”“初始化antarx-harness文档体系”或明确要求执行 `/init` 命令时触发。用于在当前项目目录创建 AGENTS.md、ARCHITECTURE.md 与 docs 分层目录及持续开发工作流基础文档；若目标文件或目录已存在则直接跳过，严禁覆盖已有内容，且不执行具体需求开发。
---

# Codex 持续开发工作流初始化

这个技能只初始化持续开发工作流骨架，不执行具体需求开发。

## 执行目标

- 在当前项目根目录创建以下结构，缺失才创建，已有必须 SKIP：
  - `AGENTS.md`
  - `ARCHITECTURE.md`
  - `docs/request-clarify/index.md`
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
   - 文件：从 `assets/` 中按相同相对路径复制模板。
   - 文件仅在目标不存在时复制；若已存在则打印 `SKIP` 并保持原内容不变。
   - 禁止删除、重命名、覆盖现有文件。
4. 执行后输出简要结果：
   - 新建了哪些目录/文件
   - 跳过了哪些已存在项
5. 输出只包含新建和跳过的目录/文件，不输出项目业务内容、需求分析、设计建议或开发计划。

## 资产组织

- 模板文件放在 `assets/` 下，路径与目标项目内的落点保持一致。
- 例如 `assets/AGENTS.md` 复制到项目根目录 `AGENTS.md`。
- 例如 `assets/docs/PROGRESS.md` 复制到项目内 `docs/PROGRESS.md`。
- 调整初始化模板时优先编辑 `assets/`，不要把长模板内联进脚本或 `SKILL.md`。

## 约束

- 仅在用户明确要求初始化目录结构时执行。
- 任何情况下都不覆盖已存在文件内容。
- 初始化产物不得包含具体项目业务内容。
- 若遇到权限问题或路径异常，停止写入并反馈错误。
