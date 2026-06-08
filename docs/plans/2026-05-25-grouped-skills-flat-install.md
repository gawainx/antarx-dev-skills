# Grouped Skills Flat Install

> **给 Codex：** 必须逐任务实现此计划。

**目标：** 将仓库内 skills 整理为二级分类目录，同时保持本地 Codex 安装目录扁平，避免改变 skill 名称和触发方式。

**相关设计文档：** 本轮调研结论已在对话中确认，未单独保存设计文档。

**架构：** 源码目录采用 `skills/<category>/<skill-name>/SKILL.md`。同步脚本递归发现包含 `SKILL.md` 的 skill 目录，并复制到 `~/.codex/skills/<skill-name>/`。校验脚本使用同一发现模型，防止同名 skill 覆盖。

**技术栈：** Bash、`rsync`、`cp`、`diff`、Codex Agent Skills 文件结构。

**范围 / 非范围：** 本次只迁移仓库组织和同步/校验脚本，不改 skill frontmatter 的 `name`，不改 Codex 全局 AGENTS 同步策略，不引入新的打包格式。

---

## 阶段 #1：分组迁移与扁平安装兼容

### 任务 #1：改造同步与校验脚本

**状态：** 已完成

**文件：**
- 修改：`scripts/sync_to_local.sh`
- 修改：`scripts/doctor.sh`
- 修改：`skills/maintenance/skill-improvement-ax/scripts/compare_skill_copies.sh`
- 创建：`skills/maintenance/skill-improvement-ax/scripts/find_source_skill.sh`
- 验证：`./scripts/sync_to_local.sh --dry-run`、`./scripts/sync_to_local.sh`、`./scripts/doctor.sh`

- 功能：递归发现源码 skill，安装时保持 `~/.codex/skills/<skill-name>/` 扁平结构。
- 实现说明：以包含 `SKILL.md` 的目录作为 skill 源目录，使用目录 basename 作为安装名；发现同名源码 skill 时失败，避免覆盖。
- 预期验证结果：`dry-run` 能列出所有二级目录中的 skill，`doctor` 能比较源码目录与扁平安装目录。
- 完成时间：2026-05-25

### 任务 #2：移动 skills 到二级分组

**状态：** 已完成

**文件：**
- 修改：`skills/**`
- 验证：`find skills -maxdepth 3 -name SKILL.md -print | sort`

- 功能：将现有 skill 目录移动到语义分类目录下。
- 实现说明：不修改 skill 目录 basename，不修改 `SKILL.md` frontmatter 的 `name`。
- 预期验证结果：所有 skill 均位于 `skills/<category>/<skill-name>/SKILL.md`。
- 完成时间：2026-05-25

### 任务 #3：更新仓库文档和内部引用

**状态：** 已完成

**文件：**
- 修改：`README.md`
- 修改：`AGENTS.md`
- 修改：`.codex/INSTALL.md`
- 修改：`skills/maintenance/skill-improvement-ax/references/workflow.md`
- 修改：`skills/maintenance/writing-skills/SKILL.md`
- 修改：`skills/knowledge/experience-triage/SKILL.md`
- 验证：`rg -n "skills/<skill-name>|find \"\\$SRC_SKILLS_DIR\"|maxdepth 1" ...`

- 功能：让维护说明与新的源码分组、安装扁平化模型一致。
- 实现说明：保留历史进度文件中的旧路径记录，不修改历史事实。
- 预期验证结果：面向当前工作流的文档不再要求 `skills/<skill-name>/SKILL.md`。
- 完成时间：2026-05-25
