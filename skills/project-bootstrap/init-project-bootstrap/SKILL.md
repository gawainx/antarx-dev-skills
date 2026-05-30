---
name: init-project-bootstrap
description: 当用户提及“代码仓初始化”“初始化代码仓”“初始化目录”“初始化项目结构”“初始化项目文档路径”“初始化 Codex 持续开发工作流”“初始化 antarx-harness 文档体系”或明确要求执行 `/init` 命令时触发；若同时提及 simple、lightweight、轻量、极简、轻量 harness、初始化轻量 harness、轻量化 agent 流程等表达，则使用轻量分支。用于在当前项目目录创建缺失的 AGENTS.md、ARCHITECTURE.md 与 docs 工作流骨架，必要时初始化 Git 仓库，并提交本次新增文档；已有内容必须跳过，严禁覆盖。
---

# Codex 持续开发工作流初始化

这个技能只初始化持续开发工作流骨架，不执行具体需求开发。

## 分支选择

- 默认走全量初始化流程。
- 只有用户在初始化请求中明确提及 `simple`、`lightweight`、`轻量`、`极简`、`轻量 harness`、`初始化轻量 harness`、`轻量化 agent 流程` 等表达时，才走轻量初始化流程。
- 不要把拼写错误或无关近似词当作轻量分支触发词；分支选择必须能从用户原话中直接看出轻量意图。

## 全量执行目标

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

## 轻量执行目标

- 在当前项目根目录创建以下结构，缺失才创建，已有必须 SKIP：
  - `AGENTS.md`，从 `assets-simple/AGENTS.simple.md` 复制而来。
  - `docs/ARCHITECTURE.md`
  - `docs/PROGRESS.md`
  - `docs/requirements/index.md`
  - `docs/requirements/requirement-template.md`
- 轻量流程使用 `REQ-NNNN` 形式的递增需求编号跟踪开发活动；创建新需求前必须检查 `docs/requirements/index.md` 和已有需求文件，使用当前最大编号加一。
- 单个需求的需求澄清、设计文档、开发计划、验证记录和验收记录必须放在同一个需求文件中。
- 轻量流程不创建全量流程中的 request-clarify、design-docs、exec-plans、product-specs、generated、references 等目录，除非用户另行要求。

## 执行步骤

1. 读取并确认当前工作目录（项目根目录）。
2. 根据分支选择运行初始化脚本：
   - 全量流程：运行 `scripts/init_project_structure.sh`。
   - 轻量流程：运行 `scripts/init_project_structure.sh --simple`。
3. 脚本内必须遵守：
   - 执行文件创建前检查当前目录 Git 状态；若当前目录不在 Git 仓库中，先执行 `git init`。
   - 目录：使用 `mkdir -p`，天然幂等。
   - 全量文件：从 `assets/` 中按相同相对路径复制模板。
   - 轻量文件：从 `assets-simple/` 中复制模板，其中 `AGENTS.simple.md` 必须落到目标项目的 `AGENTS.md`。
   - 文件仅在目标不存在时复制；若已存在则打印 `SKIP` 并保持原内容不变。
   - 禁止删除、重命名、覆盖现有文件。
   - 初始化完成后只暂存并提交本次新建的 harness 文档文件，不提交目标项目中已有的其他改动。
   - 若本次没有新建文件，不创建空提交。
   - 初始化提交信息固定使用 `chore: initialize antarx harness docs`。
4. 执行后输出简要结果：
   - 新建了哪些目录/文件
   - 跳过了哪些已存在项
   - 是否初始化 Git 仓库，以及是否提交了新建文档
5. 输出只包含新建和跳过的目录/文件，不输出项目业务内容、需求分析、设计建议或开发计划。

## 资产组织

- 全量模板文件放在 `assets/` 下，路径与目标项目内的落点保持一致。
- 轻量模板文件放在 `assets-simple/` 下，路径与目标项目内的落点保持一致；只有 `AGENTS.simple.md` 例外，它复制到目标项目根目录 `AGENTS.md`。
- 例如 `assets/AGENTS.md` 复制到项目根目录 `AGENTS.md`。
- 例如 `assets/docs/PROGRESS.md` 复制到项目内 `docs/PROGRESS.md`。
- 调整初始化模板时优先编辑 `assets/`，不要把长模板内联进脚本或 `SKILL.md`。

## 约束

- 仅在用户明确要求初始化目录结构时执行。
- 任何情况下都不覆盖已存在文件内容。
- 初始化产物不得包含具体项目业务内容。
- 初始化提交只能包含本次创建的 harness 文档文件，不能混入目标项目既有业务改动。
- 若遇到权限问题或路径异常，停止写入并反馈错误。
