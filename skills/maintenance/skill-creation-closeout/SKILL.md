---
name: skill-creation-closeout
description: 当本轮使用 skill-creator 创建或更新 skill 后使用；询问用户是否将该 skill 纳入 antarx-dev-skills 托管。用户确认前不得导入、同步、删除或修改任何 skill；用户只同意托管但未指定分类时，先判断合适分类并使用该分类继续导入。
---

# Skill Creation Closeout

## 目的

在 `skill-creator` 创建或更新 skill 后，做一次收尾确认：这个 skill 是否需要进入 `antarx-dev-skills` 仓库托管。

## 触发条件

使用本 skill，当：

- 本轮刚使用 `skill-creator` 创建了新 skill。
- 本轮刚使用 `skill-creator` 更新了已有 skill。
- 用户要求把刚创建的 skill 纳入 `antarx-dev-skills`。
- 用户询问刚创建的 skill 如何同步到本仓库。

不要使用本 skill，当：

- 用户只是安装第三方 skill。
- 用户只是浏览、列出或搜索本地 skills。
- 用户明确说该 skill 不需要托管。
- 用户要求批量同步所有本地 skills。

## 必须先询问

用户未确认前，不得复制、移动、删除、同步或修改任何 skill。

询问格式：

```text
刚创建/更新的 `<skill-name>` 目前在 `~/.codex/skills/<skill-name>/`。是否要纳入 antarx-dev-skills 托管？

我建议放到 `<category>` 分类；如果你同意托管但不指定分类，我会使用这个分类。
```

## 分类判断

用户同意托管但未指定分类时，直接使用你判断出的分类，不要把缺少分类当作阻塞点。

优先使用这些分类：

- `maintenance`：skill 创建、更新、安装、同步、发布、仓库维护。
- `quality`：调试、测试、验证、评审、质量门禁。
- `planning`：需求澄清、设计文档、开发计划。
- `memory`：长期记忆、进度记录、知识沉淀。
- `git`：worktree、分支、合并、提交、PR 收尾。
- `collaboration`：头脑风暴、代码评审协作、多代理协作。
- `schema`：JSON Schema、结构化数据设计。
- `ui`：界面布局、视觉和交互实现规范。
- `project-bootstrap`：项目初始化、目录结构、基础文档。

无法可靠判断时，使用 `maintenance`。

## 用户确认后

1. 解析 `antarx-dev-skills` 仓库路径：
   - 优先使用当前工作目录。
   - 否则读取 `~/.codex/skills/skill-improvement-ax/.skill-improvement-ax.env` 中的 `ANTARX_DEV_SKILLS_REPO`。
   - 如果无法解析，停止并请用户提供仓库路径。

2. 检查：
   - `~/.codex/skills/<skill-name>/SKILL.md` 存在。
   - `<repo>/skills/<category>/<skill-name>/` 不存在。
   - `<skill-name>` 不在黑名单：`skill-creator`、`skill-installer`、`swiftui-macos-llm-chat-module`。
   - `SKILL.md` frontmatter 的 `name` 与 `<skill-name>` 一致。

3. 导入：
   - 运行 `scripts/import_installed_skill.sh <skill-name> <category>`。
   - 脚本只复制安装目录中的 skill 到仓库源码目录。
   - 脚本不删除安装目录中的原 skill。

4. 验证：
   - 运行 `./scripts/sync_to_local.sh --dry-run`。
   - 运行 `./scripts/sync_to_local.sh`。
   - 运行 `./scripts/doctor.sh`。

## 用户拒绝后

不做任何文件操作。简短说明该 skill 会继续保留在当前安装位置，不纳入本仓库托管。
