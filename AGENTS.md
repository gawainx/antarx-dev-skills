# 仓库指南

## 项目结构与模块组织
本仓库是托管 agent skills 的单一事实源（SSOT），面向 Codex、Grok Build 与 Claude Code。默认托管内容包含 `skills/` 和 Codex 的 `DESIGN.md`；`AGENTS.md.root` 是模板，除非用户明确选择同步，否则不得同步。新增或更新可复用 skill 时，放在 `skills/<category>/<skill-name>/SKILL.md`；只有在直接需要时，才把配套文件放在对应 skill 旁边。运维脚本放在 `scripts/`，当前包括用于部署的 `sync_to_local.sh` 和用于一致性检查的 `doctor.sh`。参考资料和计划放在 `docs/`。

## 编码风格与命名约定
1. Shell 脚本使用 Bash，并启用 `set -euo pipefail`；新增脚本改动保持一致。除非文件已经使用中文文本，否则优先使用 ASCII，本仓库的若干核心文档已经使用中文。skill 目录使用小写短横线命名，例如 `skills/collaboration/requesting-code-review/`。`SKILL.md` 保持简洁、行动导向，并明确它覆盖的触发条件。
2. Skills （技能）需要使用简体中文作为主要语言编写内容；技能名以及 `openai.yaml` 的 display_name 字段优先使用英文。

## Agent 专用说明
1. 不要把 `~/.codex/skills`、`~/.grok/skills`、`~/.claude/skills` 当成源码编辑位置。
2. 受管 skill 的安装项是指向本仓库 `skills/<category>/<skill-name>/` 的符号链接。
3. 修改 skill 时只改本仓库源码，并验证本次差异、格式及相关引用。源码树按分类分组，安装目录保持扁平；源码维护与本机安装是独立操作。
4. 以下技能默认仅安装到 Codex（强绑定 Codex 运维闭环），在 Grok/Claude 目标下跳过：`skill-improvement-ax`、`skill-creation-closeout`、`workflow-review-packager`。
5. 除非用户明确要求，并且目标文件已经审阅或备份，否则不要把 `AGENTS.md.root` 同步到 Codex 全局 AGENTS 文件。

## 惰性安装

- 除非用户明确要求安装技能，否则禁止执行任何安装、重新安装或安装同步，包括 `scripts/sync_to_local.sh`、创建安装链接、复制到技能发现目录，以及通过其他脚本或工具间接安装。修改、审查、验证、提交技能和修复安装检查失败均不构成安装授权。
- 仅安装用户明确指定的技能和目标；用户没有要求安装全部技能时，不得运行批量安装全部技能的同步脚本。不得把历史安装状态或此前的安装授权视为本次重新安装授权。
- 普通源码维护不运行安装同步，也不以 `doctor.sh` 的全部技能已安装检查作为完成闸门。未安装是正常状态，不得为使检查通过而安装技能。
- 用户明确要求安装时，先核对安装范围和副作用，再执行对应预检、安装及验证；不得附带修改 shell 配置或全局 AGENTS，除非这些操作也已明确授权。
- 用户要求卸载时，删除来源已确认的安装项及受管安装记录，验证没有残留；不得在卸载后的验证或收尾阶段重新安装。其他文档或技能中的自动同步要求不得作为绕过本节的理由。
