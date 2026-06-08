# Symlink Skill Install Scope

## 目标

将本仓库的 skill 安装模型从“复制到本地安装目录”改为“通过符号链接安装”。

仓库仍然是唯一事实源，源码目录保持在 `skills/<category>/<skill-name>/`。Codex 安装目录仍然保持扁平结构，即 `~/.codex/skills/<skill-name>`，但每个受管 skill 的安装项改为指向源码 skill 目录的符号链接。

```text
skills/<category>/<skill-name>/
        |
        | 符号链接
        v
~/.codex/skills/<skill-name>
```

## 已确认需求

### 1. 保留源码分组结构

源码 skill 保持现有分组结构：

```text
skills/<category>/<skill-name>/SKILL.md
```

安装名继续使用源码目录的 basename：

```text
<skill-name>
```

本次改造不重命名 skill，不修改 `SKILL.md` frontmatter 中的名称。

### 2. 保留 Codex 扁平安装结构

Codex 仍然从扁平安装目录发现 skills：

```text
~/.codex/skills/<skill-name>
```

变化点是每个受管安装项从复制目录变为指向源码 skill 目录的符号链接。

### 3. 用链接安装替换复制同步

`scripts/sync_to_local.sh` 不再用 `rsync`、`cp` 或目录替换来安装受管 skills。

对每个受管源码 skill，脚本需要：

- 从 `skills/**/SKILL.md` 发现源码 skills；
- 在修改安装目录前校验安装名是否重复；
- 必要时创建 `CODEX_SKILLS_DIR`；
- 将 `CODEX_SKILLS_DIR/<skill-name>` 创建或更新为指向对应源码 skill 目录的符号链接；
- 保留现有黑名单 skill 处理逻辑；
- 保留 `AGENTS.md.root` 显式 opt-in 同步逻辑。

### 4. 用链接校验替换 diff 校验

`scripts/doctor.sh` 不再把受管安装项视为独立副本。

对每个受管源码 skill，校验脚本需要确认：

- `CODEX_SKILLS_DIR/<skill-name>` 存在；
- 安装项是符号链接；
- 符号链接解析后指向预期源码 skill 目录；
- 符号链接目标存在且包含 `SKILL.md`；
- 黑名单 skills 不存在于仓库源码树；
- 源码安装名重复时仍然失败。

源码和安装项已经通过链接指向同一目录，继续比较内容差异没有意义。

### 5. 只替换受管安装项

保留现有受管 manifest 概念。

`.antarx-managed-skills` 继续记录受管安装名。源码 skill 被删除或重命名后，同步脚本仍然可以据此清理 stale 受管安装项。

从旧复制安装迁移到符号链接安装时，脚本只替换已知受管项。如果 `CODEX_SKILLS_DIR/<skill-name>` 已存在未受管的非符号链接目录或文件，脚本必须停止并报告冲突，不能覆盖。

### 6. 移除 `.skill-improvement-ax.env`

现有 `.skill-improvement-ax.env` 只保存一个值：

```bash
ANTARX_DEV_SKILLS_REPO=/absolute/path/to/antarx-dev-skills
```

它的用途是让已安装的 `skill-improvement-ax` 副本反查源码仓库路径。

链接安装后，这个文件不再需要。安装路径会解析到仓库源码目录：

```text
~/.codex/skills/skill-improvement-ax -> repo/skills/maintenance/skill-improvement-ax
```

`skill-improvement-ax/scripts/resolve_source_repo.sh` 可以从脚本自身真实路径向上推导仓库根目录：

```text
scripts/
..        skill-improvement-ax/
../..     maintenance/
../../..  skills/
../../../.. 仓库根目录
```

本次改造需要：

- 停止生成 `.skill-improvement-ax.env`；
- 删除文档中要求用户修复 `.skill-improvement-ax.env` 的旧说明；
- 更新 `resolve_source_repo.sh`，让它从脚本路径推导并校验源码仓库；
- 移除链接安装后不再适用的“源码副本 vs 安装副本”比较行为。

### 7. 更新依赖的维护流程文档

以下引用需要更新为链接安装语义，不能继续描述复制同步：

- `README.md`
- `AGENTS.md`
- `AGENTS.md.root`
- `skills/maintenance/skill-improvement-ax/SKILL.md`
- `skills/maintenance/skill-improvement-ax/references/workflow.md`
- `skills/maintenance/writing-skills/SKILL.md`
- `skills/knowledge/experience-triage/SKILL.md`
- 其它当前维护流程中写到“受管 skills 会复制到 `~/.codex/skills`”的文本

历史进度记录和已完成历史计划只记录当时事实，不因为当前行为改变而重写。

## 不纳入范围

- 不改变仓库源码目录结构。
- 不改变 skill 名称或 skill frontmatter。
- 不改变 Codex 扁平 skill 发现目录。
- 不改变受保护的 `AGENTS.md.root` 同步策略。
- 不新增打包格式或注册表。
- 不新增用于 skill 安装的 UI 或插件层。

## 验收标准

满足以下条件时，本次改造完成：

- `./scripts/sync_to_local.sh --dry-run` 能预览符号链接安装动作。
- `./scripts/sync_to_local.sh` 将受管 skills 安装为符号链接。
- `./scripts/doctor.sh` 通过校验符号链接目标完成检查，不再依赖复制内容 diff。
- `skill-improvement-ax` 不依赖 `.skill-improvement-ax.env` 也能解析源码仓库。
- 当前维护文档不再说受管 skills 是复制出来的本地副本。
- stale 受管 skill 仍然能通过 manifest 清理。
- 未受管的非符号链接安装冲突会被报告，不会被覆盖。
