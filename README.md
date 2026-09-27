# antarx-dev-skills

面向持续开发工作流的 agent skills 仓库，可通过 skills.sh 安装到 Codex 等支持 skills 的 agent。

本仓库目标：
- 在 `skills/<category>/<skill-name>/` 下沉淀可复用的开发技能
- 通过 `npx skills@latest add gawainx/antarx-dev-skills` 进行公开安装
- 通过 Codex 原生 skills 发现机制进行加载
- 维护最小但清晰的工程结构，便于长期迭代
- 作为 `skills/` 的单一事实源（SSOT）

## 快速开始

### 安装到 Codex 或其他 agent

```bash
npx skills@latest add gawainx/antarx-dev-skills
```

安装时选择需要的 skills 和目标 agent；默认安装到当前项目，添加 `-g` 则全局安装。全部现存技能由官方 CLI 从 `skills/` 自动发现。

### 当前公开 skills

- `dida-task-creator`：根据项目上下文创建滴答清单任务
- `dispatching-parallel-agents`：把独立任务并行派发给子代理
- `merge-worktree-to-source-branch`：把 worktree 改动合回源分支
- `using-git-worktrees`：需要隔离工作区时创建和使用 worktree
- `design-plan-doc-writer`：需求澄清后产出设计文档与开发计划
- `requirement-clarification`：结合仓库现状澄清需求
- `systematic-debugging`：按根因调查流程处理 bug 和失败
- `test-driven-development`：按 RED-GREEN-REFACTOR 实现功能或修复
- `swiftui-macos-settings-window-pattern`：构建 macOS SwiftUI Settings 窗口
- `ui-layout-discipline`：检查和实现稳定 UI 布局

### 项目文档保存

需求澄清、设计文档与开发计划默认保存在同一个 `r001-*.md` 文档中，按二级标题逐步补充，需求编号递增。DEVONthink MCP 可用时，优先调用 awesome-devonthink 的 `dt-writing-project-documents` 技能完成读取、修订与保存；该技能需要在使用环境中可读取，源码见 [awesome-devonthink](https://github.com/gawainx/awesome-devonthink/tree/master/using-dt-skills)。本仓库不自动安装该依赖。

仅在 DEVONthink MCP 未安装或未启用时，自动保存到当前项目根目录的 `docs/r001-*.md`。DEVONthink 操作遵循对应 DT 技能。

`init-project-bootstrap` 已日落，不再提供安装入口。本机归档位于 `.deprecated/init-project-bootstrap/`；`.deprecated/` 被 Git 忽略，归档副本不随仓库分发，历史版本可从 Git 历史恢复。

## 目录结构

- `.codex/`：Codex 安装与接入说明
- `skills/`：技能定义（核心），源码按二级分类目录整理，由 `npx skills` 安装和管理
- `scripts/`：仅安装与检查 Codex 的 DESIGN 和 AGENTS 全局文件
- `AGENTS.root.md`：Codex 全局指令的链接安装源（需显式启用）
- `DESIGN.md`：Codex 全局设计规范，安装时链接到 `~/.codex/DESIGN.md`
- `docs/`：设计文档与计划
- `commands/`：可选的命令模板
- `agents/`：可选的 agent 指令模板
- `hooks/`：可选的 hook 配置
- `lib/`：工具脚本与公共逻辑
- `tests/`：测试与验证用例

## 技能管理

```bash
# 列出本仓库提供的技能，不安装
npx skills add gawainx/antarx-dev-skills --list
# 全局安装到 Codex，交互选择技能
npx skills add gawainx/antarx-dev-skills -g -a codex
# 查看全局已安装技能
npx skills list -g
# 更新或卸载指定技能
npx skills update requirement-clarification -g
npx skills remove requirement-clarification -g
```

技能安装位置、安装记录与更新由官方 CLI 管理。本仓库不再维护技能安装器，也不创建指向源码仓库的技能安装链接。只修改仓库源码不会自动更新已安装内容。

## Codex 全局文件

`DESIGN.md` 和 `AGENTS.root.md` 的安装与技能管理独立。只有明确需要安装这些文件时才运行：

```bash
# 预览 DESIGN 安装
./scripts/sync_to_local.sh --dry-run
# 安装 DESIGN
./scripts/sync_to_local.sh
# 同时安装 DESIGN 和 AGENTS
./scripts/sync_to_local.sh --sync-agents
# 检查全局文件链接
./scripts/doctor.sh --check-agents
```

脚本只操作这两个全局文件。目标位置可通过 `.env` 配置，参考 `.env.example`。已有 DESIGN 非本项目来源时停止并提醒；AGENTS 保留显式启用和 `--force-agents` 替换规则。仓库 `AGENTS.md` 仅约束项目开发，不作为安装源。
