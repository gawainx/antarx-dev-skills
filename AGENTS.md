# 仓库指南

## 项目结构与模块组织
本仓库是托管 agent skills 的单一事实源（SSOT），面向 Codex、Grok Build 与 Claude Code。默认托管内容包含 `skills/` 和 Codex 的 `DESIGN.md`；`AGENTS.root.md` 是 Codex 全局 AGENTS 的链接安装源，除非用户明确选择安装，否则不得安装。本项目的 `AGENTS.md` 仅约束仓库开发，严格禁止作为安装源。新增或更新可复用 skill 时，放在 `skills/<category>/<skill-name>/SKILL.md`；只有在直接需要时，才把配套文件放在对应 skill 旁边。技能安装、更新、查询和卸载统一使用 `npx skills`。`scripts/sync_to_local.sh` 和 `scripts/doctor.sh` 仅用于 Codex 全局 DESIGN 与 AGENTS 文件的安装和检查，不管理技能。参考资料和计划放在 `docs/`。

## 编码风格与命名约定
1. Shell 脚本使用 Bash，并启用 `set -euo pipefail`；新增脚本改动保持一致。除非文件已经使用中文文本，否则优先使用 ASCII，本仓库的若干核心文档已经使用中文。skill 目录使用小写短横线命名，例如 `skills/collaboration/dispatching-parallel-agents/`。`SKILL.md` 保持简洁、行动导向，并明确它覆盖的触发条件。
2. Skills （技能）需要使用简体中文作为主要语言编写内容；技能名以及 `openai.yaml` 的 display_name 字段优先使用英文。

## Agent 专用说明
1. 不要把 `~/.codex/skills`、`~/.grok/skills`、`~/.claude/skills` 当成源码编辑位置。
2. 所有现存技能均通过 `npx skills add` 提供安装；安装位置和记录由官方 CLI 管理，不创建指向本仓库源码的技能安装链接。
3. 修改 skill 时只改本仓库源码，并验证本次差异、格式及相关引用。源码树按分类分组；源码维护与本机安装是独立操作，更新安装内容使用 `npx skills update`。

## Git 完成标准

- 所有项目只要由 Git 管理且配置了 remote，完成工作前必须验证改动、提交并成功推送远端；仅本地提交或工作区干净不算完成。

## 惰性安装

- 除非用户明确要求安装技能，否则禁止执行任何安装、重新安装或安装同步，包括 `npx skills add`、`npx skills update` 及其他会修改技能安装目录的操作。修改、审查、验证、提交技能和修复安装检查失败均不构成安装授权。
- 仅安装用户明确指定的技能和目标；用户没有要求安装全部技能时，不得使用全选或批量安装参数。不得把历史安装状态或此前的安装授权视为本次重新安装授权。
- 普通源码维护不执行技能安装或更新。未安装是正常状态，不得为使检查通过而安装技能。
- 用户明确要求安装时，先核对安装范围和副作用，再执行对应预检、安装及验证；不得附带修改 shell 配置或全局 AGENTS，除非这些操作也已明确授权。
- 用户要求卸载时，删除来源已确认的安装项及受管安装记录，验证没有残留；不得在卸载后的验证或收尾阶段重新安装。其他文档或技能中的自动同步要求不得作为绕过本节的理由。
