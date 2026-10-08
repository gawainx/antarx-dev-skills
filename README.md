# antarx-dev-skills

面向需求澄清、设计规划、开发与调试的 Agent Skills，适用于 Codex、Claude Code、Grok Build 等工具。技能统一通过 [skills CLI](https://github.com/vercel-labs/skills) 安装和管理。

## 安装

```bash
npx skills add gawainx/antarx-dev-skills
```

按提示选择技能和目标 agent。默认安装到当前项目，添加 `-g` 可全局安装。例如，全局安装到 Codex：

```bash
npx skills add gawainx/antarx-dev-skills -g -a codex
```

## 技能一览

| 技能 | 用途 |
| --- | --- |
| [requirement-clarification](skills/planning/requirement-clarification/SKILL.md) | 澄清目标、范围和验收条件 |
| [design-plan-doc-writer](skills/planning/design-plan-doc-writer/SKILL.md) | 基于已确认需求编写设计与开发计划 |
| [using-git-worktrees](skills/git/using-git-worktrees/SKILL.md) | 创建和准备隔离工作区 |
| [merge-worktree-to-source-branch](skills/git/merge-worktree-to-source-branch/SKILL.md) | 将 worktree 改动快进合回源分支 |
| [dispatching-parallel-agents](skills/collaboration/dispatching-parallel-agents/SKILL.md) | 将独立任务派发给并行子代理 |
| [systematic-debugging](skills/quality/systematic-debugging/SKILL.md) | 根据证据定位问题并验证修复 |
| [test-driven-development](skills/quality/test-driven-development/SKILL.md) | 按 RED → GREEN → REFACTOR 开发 |
| [ui-layout-discipline](skills/ui/ui-layout-discipline/SKILL.md) | 检查和修复 UI 布局 |
| [swiftui-macos-settings-window-pattern](skills/ui/swiftui-macos-settings-window-pattern/SKILL.md) | 构建 macOS SwiftUI 设置窗口 |
| [dida-task-creator](skills/integration/dida-task-creator/SKILL.md) | 使用本地 dida CLI 创建滴答清单任务 |
| [writing-flavor-review](skills/writing/writing-flavor-review/SKILL.md) | 审查文章中的怪味、AI 味并提供局部修改建议 |

## 更新与卸载

```bash
# 查看仓库提供的技能
npx skills add gawainx/antarx-dev-skills --list

# 查看全局已安装技能
npx skills list -g

# 更新或卸载指定的全局技能
npx skills update requirement-clarification -g
npx skills remove requirement-clarification -g
```

安装位置与记录由 CLI 管理。修改仓库源码后，通过 CLI 更新已安装技能。

## 项目文档保存

需求澄清、设计和开发计划默认保存在同一文档中，按章节逐步补充。DEVONthink MCP 可用时，调用 [awesome-devonthink](https://github.com/gawainx/awesome-devonthink/tree/master/using-dt-skills) 的 `dt-writing-project-documents` 技能保存；使用该方式需另行提供对应技能。MCP 未安装或未启用时，保存到当前项目根目录的 `docs/`。

## Codex / Claude 全局文件

本仓库另提供 [DESIGN.md](DESIGN.md) 和 [AGENTS.root.md](AGENTS.root.md)，按需独立安装。`AGENTS.root.md` 可同时作为 Codex 的 `AGENTS.md` 和 Claude Code 的 `CLAUDE.md` 安装源。在本地仓库根目录运行：

```bash
# 预览或安装 DESIGN（仅 Codex）
./scripts/sync_to_local.sh --dry-run
./scripts/sync_to_local.sh

# 同时安装 DESIGN 和 Codex AGENTS
./scripts/sync_to_local.sh --sync-agents

# 同时安装 DESIGN 和 Claude CLAUDE.md
./scripts/sync_to_local.sh --sync-claude

# 检查 DESIGN；添加 --check-agents / --check-claude 同时检查对应链接
./scripts/doctor.sh
```

这两个脚本仅处理全局文件。目标路径配置见 [.env.example](.env.example)。已有 DESIGN 非本项目来源时停止；替换已有 AGENTS 需明确使用 `--sync-agents --force-agents`，替换已有 CLAUDE.md 需明确使用 `--sync-claude --force-claude`。

## 维护

技能源码位于 `skills/<category>/<skill-name>/`，开发约定见 [AGENTS.md](AGENTS.md)。在仓库中编辑、提交和推送源码；技能安装与更新由使用者通过 CLI 执行。
