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

安装时选择需要的 skills 和目标 agent。`.claude-plugin/plugin.json` 是 skills.sh 读取的仓库发布清单；它只声明本仓库哪些目录是可安装 skill，不限制运行时只能用于 Claude Code。

### 当前公开 skills

- `brainstorming`：需求或方案不清晰时进行共创讨论
- `dispatching-parallel-agents`：把独立任务并行派发给子代理
- `receiving-code-review`：接收评审意见前先验证再落地
- `requesting-code-review`：任务完成后发起代码评审
- `merge-worktree-to-source-branch`：把 worktree 改动合回源分支
- `using-git-worktrees`：需要隔离工作区时创建和使用 worktree
- `experience-triage`：判断经验应沉淀到哪一层
- `writing-skills`：创建、修改和验证 skills
- `architecture-design`：讨论模块边界、依赖方向和数据流
- `design-plan-doc-writer`：需求澄清后产出设计文档与开发计划
- `requirement-clarification`：结合仓库现状澄清需求
- `writing-plans`：为多步骤实现编写开发计划
- `init-project-bootstrap`：初始化 Codex 持续开发文档骨架
- `project-structure-migration`：迁移已有项目文档结构
- `systematic-debugging`：按根因调查流程处理 bug 和失败
- `test-driven-development`：按 RED-GREEN-REFACTOR 实现功能或修复
- `verification-before-completion`：完成前运行验证并核对输出
- `json-schema-design-assistant`：设计和增强 JSON Schema
- `swiftui-macos-settings-window-pattern`：构建 macOS SwiftUI Settings 窗口
- `ui-layout-discipline`：检查和实现稳定 UI 布局

## 目录结构

- `.claude-plugin/`：skills.sh 公开安装清单
- `.codex/`：Codex 安装与接入说明
- `skills/`：技能定义（核心），源码按二级分类目录整理，安装后通过符号链接扁平化到 Codex skills 目录
- `scripts/`：本地同步与校验脚本
- `AGENTS.md.root`：全局代理行为模板（默认不自动同步）
- `docs/`：设计文档与计划
- `commands/`：可选的命令模板
- `agents/`：可选的 agent 指令模板
- `hooks/`：可选的 hook 配置
- `lib/`：工具脚本与公共逻辑
- `tests/`：测试与验证用例

## 维护者本地同步方案

请先阅读：`./.codex/INSTALL.md`

### 1. 一次性准备

```bash
git clone <your-repo-url> ~/code/vibeProjects/antarx-dev-skills
cd ~/code/vibeProjects/antarx-dev-skills
```

### 2. 安装到本机 Codex
顺序执行如下脚本：

```bash
# 预览所有技能
./scripts/sync_to_local.sh --dry-run
# 执行链接安装动作
./scripts/sync_to_local.sh
```

说明：
- 默认递归发现 `skills/**/SKILL.md`，并在 `~/.codex/skills/<skill-name>` 创建指向源码 skill 目录的符号链接
- 源码目录可以按二级分类整理；本地安装目录通过链接保持扁平，便于 Codex 发现和触发
- 默认不同步 `AGENTS.md.root`，避免覆盖 Codex 系统级 `AGENTS.md`
- 可通过环境变量覆盖目标路径：

```bash
CODEX_SKILLS_DIR=/custom/skills ./scripts/sync_to_local.sh
```

如确需同步 AGENTS 模板，必须显式 opt in：

```bash
CODEX_AGENTS_FILE=/custom/AGENTS.md ./scripts/sync_to_local.sh --sync-agents
```

如果目标 AGENTS 文件已存在且内容不同，脚本会拒绝覆盖。确认已备份并接受覆盖风险后，才使用 `--sync-agents --force-agents`。

### 3. 一致性校验

```bash
./scripts/doctor.sh
```

该命令会同时校验本地 Codex symlink 安装状态和 `.claude-plugin/plugin.json` 的公开发布清单。

### 4. 跨设备 skill 同步流程

统一流程（任意设备都一样）：

1. 在仓库内编辑 `skills/<category>/<skill-name>/`
2. 提交并推送到远端
3. 另一台设备 `git pull`
4. 运行 `./scripts/sync_to_local.sh`
5. 运行 `./scripts/doctor.sh`
