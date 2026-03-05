# 0001 - 初始化 antarx-dev-skills 项目结构

## What

目标是在当前仓库完成第一版工程初始化，仿照 `superpowers` 的核心结构，并结合当前诉求只保留 Codex 适配能力：

- 初始化核心目录：`agents/`、`commands/`、`docs/`、`docs/plans/`、`hooks/`、`lib/`、`skills/`、`tests/`
- 初始化 Codex 适配目录：`.codex/`
- 提供面向 Codex 的 skills 安装、验证、更新、卸载说明
- 提供仓库级 README 与基础 `.gitignore`

## Why

当前仓库为空，无法直接承载 skills 的持续维护工作。通过一次性初始化：

- 建立稳定目录边界，降低后续新增 skill 的组织成本
- 明确 Codex 接入路径（通过 `~/.agents/skills` 软链接）
- 让仓库具备“可读、可用、可验证”的最小可运行状态

## How

### 1. 结构设计

以 `superpowers` 为参照，保留核心目录，不引入当前不需要的平台目录（如 `.claude-plugin`、`.cursor-plugin`、`.opencode`）。

### 2. Codex 接入方案

在 `.codex/INSTALL.md` 提供标准流程：

1. clone 到 `~/.codex/antarx-dev-skills`
2. 建立软链接 `~/.agents/skills/antarx-dev-skills -> ~/.codex/antarx-dev-skills/skills`
3. 重启 Codex 完成 skills 发现

### 3. 文档与可维护性

- `README.md` 说明仓库目标与目录职责
- `docs/plans/0001-init-structure.md` 记录初始化决策与执行计划
- `.gitignore` 过滤本地无关文件

## 代码预期改动范围

新增：

- `.gitignore`
- `README.md`
- `.codex/INSTALL.md`
- `docs/plans/0001-init-structure.md`

新增目录：

- `.codex/`
- `agents/`
- `commands/`
- `docs/`
- `docs/plans/`
- `hooks/`
- `lib/`
- `skills/`
- `tests/`

## 破坏性变更评估

无破坏性变更。本次为纯新增初始化，不修改业务逻辑。

## 测试用例与验证方式

1. 结构验证
- 命令：`find . -maxdepth 2 -type d | sort`
- 预期：上述目录均存在

2. 文档验证
- 命令：`ls -la .codex/INSTALL.md README.md docs/plans/0001-init-structure.md`
- 预期：文件存在且可读

3. Codex 链接验证（用户本地执行）
- 命令：`ls -la ~/.agents/skills/antarx-dev-skills`
- 预期：软链接指向 `~/.codex/antarx-dev-skills/skills`

## 开发计划

### Phase #1: 项目骨架初始化

- Task #1: 创建核心目录与 `.codex/`
  - 预期结果：目录创建完成
  - 状态：Finished

- Task #2: 创建 README 与 `.gitignore`
  - 预期结果：仓库目标和基础忽略规则明确
  - 状态：Finished

### Phase #2: Codex 接入文档化

- Task #1: 编写 `.codex/INSTALL.md`
  - 预期结果：具备可执行的安装/验证/更新/卸载步骤
  - 状态：Finished

### Phase #3: 设计与计划归档

- Task #1: 编写初始化设计文档（本文件）
  - 预期结果：What/Why/How、影响与验证路径清晰
  - 状态：Finished
