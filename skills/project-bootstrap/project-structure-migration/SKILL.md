---
name: project-structure-migration
description: 迁移已有 vibe coding 项目的文档管理体系到 antarx-harness 文档体系持续开发结构。Use when reorganizing an existing project's requirements, clarification notes, design docs, execution plans, AGENTS.md, ARCHITECTURE.md, and docs/ hierarchy into the Codex project-bootstrap layout, especially for requests like “项目结构迁移”, “迁移项目文档结构”, “把已有项目迁移到 antarx-harness 文档体系”, or “整理 vibe coding 项目的 docs 和 AGENTS”.
---

# 项目结构迁移

将已有项目迁移到 `init-project-bootstrap` 技能对应的持续开发文档体系。这个技能处理已有文档、已有 `AGENTS.md` 和缺失架构文档，因此默认采用审计优先、用户确认后执行的流程。

## 迁移原则

- 先审计，再迁移；没有明确用户确认时，只生成迁移计划，不移动、不删除、不覆盖文件。
- 保留项目已有规则，尤其是安全规则、构建命令、测试命令、业务边界和部署说明。
- 优先补齐缺失结构；对已有文件使用合并、追加或生成迁移建议，避免直接覆盖。
- 归档旧文档时保留可追溯索引，记录原路径、目标路径和分类理由。
- 对无法可靠分类的文档标记为 `needs-review`，不要静默归类。

## 目标结构

以 `init-project-bootstrap` 的结构为迁移目标：

- `AGENTS.md`
- `ARCHITECTURE.md`
- `docs/request-clarify/`
- `docs/design-docs/`
- `docs/design-docs/core-beliefs.md`
- `docs/exec-plans/active/`
- `docs/exec-plans/completed/`
- `docs/exec-plans/tech-debt-tracker.md`
- `docs/generated/`
- `docs/product-specs/`
- `docs/references/`
- `docs/DESIGN.md`
- `docs/FRONTEND.md`
- `docs/PROGRESS.md`
- `docs/PRODUCT_SENSE.md`
- `docs/QUALITY_SCORE.md`
- `docs/RELIABILITY.md`
- `docs/SECURITY.md`

## 工作流

### 1. 盘点当前项目

确认当前目录是项目根目录后，读取或扫描：

- 根目录 `AGENTS.md`、`ARCHITECTURE.md`、`README*`
- `docs/` 下全部 Markdown 文档
- 常见散落文档：`plan*`、`design*`、`requirement*`、`clarif*`、`spec*`、`progress*`、`todo*`
- 项目级配置里的构建、测试、运行命令

输出一个简短审计结论：

- 已符合目标结构的路径
- 缺失的目标路径
- 需要迁移或归档的候选文档
- 分类不确定、需要用户确认的文档

### 2. 生成迁移计划

在执行任何文件移动或内容修改前，先生成迁移计划。计划必须包含：

- `create`：要补齐的目录和模板文件
- `move`：建议移动的旧文档，包含原路径、目标路径和理由
- `merge`：建议合并到 `AGENTS.md`、`ARCHITECTURE.md` 或核心 docs 的内容
- `archive`：建议归档的旧文档和归档位置
- `needs-review`：无法自动判断归属的文档

推荐文档分类：

- 需求澄清、用户确认、范围边界 -> `docs/request-clarify/`
- 技术方案、架构决策、模块设计 -> `docs/design-docs/`
- 当前任务计划、阶段任务、实施步骤 -> `docs/exec-plans/active/`
- 已验收或明确完成的历史计划 -> `docs/exec-plans/completed/`
- 产品功能、用户流程、验收标准 -> `docs/product-specs/`
- 外部依赖、协议、调研资料 -> `docs/references/`
- 自动生成摘要、迁移报告 -> `docs/generated/`

### 3. 等待确认

除非用户已经明确要求“直接执行迁移”，否则在计划生成后停止，等待用户确认。

确认前禁止：

- 移动、重命名、删除既有文档
- 覆盖 `AGENTS.md` 或任何已有文档
- 把不确定文档归入确定目录
- 自动把执行计划归档到 `completed/`

### 4. 执行迁移

用户确认后再执行迁移：

1. 补齐缺失目录。
2. 从 `init-project-bootstrap` 的模板补齐缺失文件；已有文件不覆盖。
3. 按确认后的计划移动文档。
4. 更新 `AGENTS.md`，保留原有项目规则，并补入文档体系、阅读顺序、写回规则、命名规则和归档规则。
5. 补充或创建 `ARCHITECTURE.md`；如果缺少足够项目上下文，只写结构化占位和待补问题，不编造系统事实。
6. 更新 `docs/PROGRESS.md`，记录迁移日期、迁移范围、归档索引和未决项。
7. 将迁移报告写入 `docs/generated/project-structure-migration.md`。

### 5. 验证迁移

迁移后验证：

- 目标目录和关键文件是否存在
- 迁移报告中的原路径和目标路径是否能对应
- `AGENTS.md` 是否仍包含项目原有关键规则
- `docs/exec-plans/active/` 与 `completed/` 是否没有未经确认的自动归档
- Git diff 是否只包含迁移相关改动

## AGENTS.md 更新要求

更新 `AGENTS.md` 时加入或合并这些内容：

- 文档阅读顺序
- 需求澄清、设计文档、执行计划、产品规格、参考资料的写回位置
- 同一需求的澄清、设计、计划文档使用同名文件
- 默认命名格式：`rNNN-request-desc.md`
- 日期写在文档头部，不放入文件名
- 执行计划只有用户验收后才能从 `active/` 移到 `completed/`
- 子目录 `AGENTS.md` 只能补充或收紧局部规则，不能放宽根规则

不要移除项目已有的构建、测试、运行、发布、安全、隐私、分支和提交规则。

## 命名和归档规则

- 新需求默认使用 `rNNN-request-desc.md`。
- 模块化项目可使用模块前缀，例如 `rwNNN-request-desc.md`，但必须先在 `AGENTS.md` 中定义前缀含义。
- 同一需求在 `request-clarify/`、`design-docs/`、`exec-plans/` 中保持同名。
- 旧文档不确定是否仍有价值时，归档到 `docs/references/legacy/` 或列入 `needs-review`。
- 自动生成的审计和迁移报告放入 `docs/generated/`。

## 停止条件

遇到以下情况时停止并向用户确认：

- 当前目录不像项目根目录。
- 已有文档分类存在多个合理目标，且移动会影响后续维护。
- `AGENTS.md` 中存在与目标结构冲突的强规则。
- 文件移动会覆盖目标路径。
- 用户要求删除历史文档，但没有明确删除清单。
