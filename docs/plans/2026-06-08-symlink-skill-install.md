# Symlink Skill Install

> **给 Codex：** 按任务顺序执行此计划，完成每项后更新状态。

**目标：** 将本仓库受管 skills 从复制安装改为符号链接安装。

**相关设计文档：** `docs/2026-06-08-symlink-skill-install-scope.md`

**架构：** `scripts/sync_to_local.sh` 继续递归发现 `skills/**/SKILL.md`，但安装动作改为创建 `~/.codex/skills/<skill-name>` 到源码 skill 目录的符号链接。`scripts/doctor.sh` 改为校验链接存在、链接目标和源码目录有效性。`skill-improvement-ax` 通过脚本真实路径定位源码仓库，不再依赖 `.skill-improvement-ax.env`。

**技术栈：** Bash、`find`、`ln -s`、`readlink`、Codex Agent Skills 文件结构。

**范围 / 非范围：** 只改安装、校验、skill-improvement-ax 路径解析和当前维护文档；不改 skill 名称、源码分组结构、Codex 扁平发现目录和 `AGENTS.md.root` 受保护同步策略。

---

## 阶段 #1：脚本行为改造

### 任务 #1：改造同步脚本为符号链接安装

**状态：** Finished

**文件：**
- 修改：`scripts/sync_to_local.sh`
- 验证：`./scripts/sync_to_local.sh --dry-run`

- 功能：将受管 skill 安装项创建为指向源码 skill 目录的符号链接。
- 实现说明：保留源码发现、黑名单、重复名校验、manifest、shell env 和 AGENTS opt-in；删除复制安装和 `.managed-by-antarx-dev-skills` 标记写入；只替换 manifest 中已知受管项或已指向错误位置的受管 symlink，遇到未受管非链接冲突时失败。
- 预期验证结果：dry-run 输出链接安装动作，不再输出 `rsync` 或 copy 替换动作。
- 完成时间：2026-06-08

### 任务 #2：改造 doctor 为符号链接校验

**状态：** Finished

**文件：**
- 修改：`scripts/doctor.sh`
- 验证：`./scripts/doctor.sh`

- 功能：用链接目标校验替代源码与安装副本 diff。
- 实现说明：保留源码黑名单、重复名和源码 broken symlink 检查；对每个受管 skill 校验安装项是 symlink，解析目标等于预期源码目录，并确认目标包含 `SKILL.md`。
- 预期验证结果：链接安装后 `doctor` 返回 0；复制目录或错误链接会被报告为失败。
- 完成时间：2026-06-08

## 阶段 #2：skill-improvement-ax 路径语义改造

### 任务 #3：移除 `.skill-improvement-ax.env` 依赖

**状态：** Finished

**文件：**
- 修改：`skills/maintenance/skill-improvement-ax/scripts/resolve_source_repo.sh`
- 修改：`skills/maintenance/skill-improvement-ax/scripts/find_source_skill.sh`
- 修改：`skills/maintenance/skill-improvement-ax/scripts/compare_skill_copies.sh`
- 删除：`skills/maintenance/skill-improvement-ax/assets/skill-improvement-ax.env.example`
- 验证：`skills/maintenance/skill-improvement-ax/scripts/resolve_source_repo.sh`

- 功能：让 skill-improvement-ax 通过自身脚本真实路径定位源码仓库。
- 实现说明：`resolve_source_repo.sh` 从脚本目录向上推导仓库根目录并校验 `.git`、`skills/`、`scripts/sync_to_local.sh`；`compare_skill_copies.sh` 不再执行副本 diff，改为确认安装链接是否指向源码 skill，或删除旧比较入口并更新引用。
- 预期验证结果：不需要 `.skill-improvement-ax.env` 也能输出当前仓库根目录。
- 完成时间：2026-06-08

## 阶段 #3：文档与整体验证

### 任务 #4：更新当前维护文档

**状态：** Finished

**文件：**
- 修改：`README.md`
- 修改：`AGENTS.md`
- 修改：`AGENTS.md.root`
- 修改：`skills/maintenance/skill-improvement-ax/SKILL.md`
- 修改：`skills/maintenance/skill-improvement-ax/references/workflow.md`
- 修改：`skills/maintenance/writing-skills/SKILL.md`
- 修改：`skills/knowledge/experience-triage/SKILL.md`
- 修改：`skills/maintenance/skill-creation-closeout/SKILL.md`
- 修改：`skills/maintenance/skill-creation-closeout/scripts/import_installed_skill.sh`
- 验证：`rg -n "复制|本地副本|\\.skill-improvement-ax\\.env|compare_skill_copies|rsync -a --delete" ...`

- 功能：把当前维护说明更新为链接安装语义。
- 实现说明：历史进度记录和已完成历史计划不重写；当前可执行流程中移除复制副本、修复 `.skill-improvement-ax.env` 和副本 diff 的旧说法。
- 预期验证结果：当前维护文档不再把受管安装描述成复制副本。
- 完成时间：2026-06-08

### 任务 #5：运行完整验证

**状态：** Finished

**文件：**
- 验证：`./scripts/sync_to_local.sh --dry-run`
- 验证：`./scripts/sync_to_local.sh`
- 验证：`./scripts/doctor.sh`
- 验证：`skills/maintenance/skill-improvement-ax/scripts/resolve_source_repo.sh`

- 功能：证明链接安装、校验和路径解析闭环可用。
- 实现说明：同步会改写本机 `CODEX_SKILLS_DIR` 中的受管安装项；如果遇到未受管冲突，按脚本错误输出处理，不强制覆盖。
- 预期验证结果：所有验证命令返回 0，工作区只包含本次源码和文档改动。
- 完成时间：2026-06-08
