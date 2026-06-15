# 仓库指南

## 项目结构与模块组织
本仓库是托管 Codex skills 的单一事实源。默认托管内容仅包含 `skills/`；`AGENTS.md.root` 是模板，除非用户明确选择同步，否则不得同步。新增或更新可复用 skill 时，放在 `skills/<category>/<skill-name>/SKILL.md`；只有在直接需要时，才把配套文件放在对应 skill 旁边。运维脚本放在 `scripts/`，当前包括用于部署的 `sync_to_local.sh` 和用于一致性检查的 `doctor.sh`。参考资料和计划放在 `docs/`，例如 `docs/plans/0001-init-structure.md`。

## 构建、测试与开发命令
所有编辑和命令都从仓库根目录执行。

```bash
./scripts/sync_to_local.sh --dry-run
```
预览将链接安装到 `~/.codex/skills` 的内容。

```bash
./scripts/sync_to_local.sh
```
将托管 skills 应用到本机 Codex 安装目录。

```bash
./scripts/doctor.sh
```
校验本地安装链接是否指向仓库源码；在声明完成前，此命令应以 `0` 退出。

## 编码风格与命名约定
1. Shell 脚本使用 Bash，并启用 `set -euo pipefail`；新增脚本改动保持一致。除非文件已经使用中文文本，否则优先使用 ASCII，本仓库的若干核心文档已经使用中文。skill 目录使用小写短横线命名，例如 `skills/collaboration/requesting-code-review/`。`SKILL.md` 保持简洁、行动导向，并明确它覆盖的触发条件。
2. Skills （技能）需要使用简体中文作为主要语言编写内容；技能名以及 `openai.yaml` 的 display_name 字段优先使用英文。

## 测试指南
将 `./scripts/doctor.sh` 视为必需验证闸门，并在同步前使用 `./scripts/sync_to_local.sh --dry-run` 做安全预检。如果新增自动化测试，把测试放在 `tests/`，并按其验证的行为或脚本命名。

## Agent 专用说明
1. 不要把 `~/.codex/skills` 当成源码编辑位置。
2. 受管 skill 的安装项是指向本仓库 `skills/<category>/<skill-name>/` 的符号链接；
3. 修改 skill 时，只改本仓库源码，然后按顺序运行 dry-run sync、真实 sync 和 doctor。源码树按分类分组，但安装目录有意保持扁平：`~/.codex/skills/<skill-name>/`。
4. 除非用户明确要求，并且目标文件已经审阅或备份，否则不要把 `AGENTS.md.root` 同步到 Codex 全局 AGENTS 文件。禁止把黑名单 skills 加入托管内容：`skill-creator`、`skill-installer` 和 `swiftui-macos-llm-chat-module`。
