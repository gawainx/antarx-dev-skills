---
name: using-git-worktrees
description: 仅在明确需要隔离时使用（并行工作、脏工作区风险，或用户要求）。创建 worktree 前先请求用户批准，并说明为什么需要它。
---

# 使用 Git Worktrees

## 概览

Git worktree 会创建共享同一个仓库的隔离工作区，让你可以同时在多个分支上工作，而不需要来回切换。

**核心原则：** 系统化选择目录 + 安全验证 = 可靠隔离。

**开始时说明：** “我正在使用 using-git-worktrees 技能来设置一个隔离工作区。”

## 触发条件（窄范围）

仅当至少满足以下一个条件时使用此技能：

1. 用户明确要求使用 worktree 或隔离工作区。
2. 你必须运行并行/独立的实现流，而这些工作在同一个工作树中会互相冲突。
3. 当前工作区有意保持脏状态，并且必须隔离新改动以避免交叉污染。
4. 上层工作流明确要求隔离，并且用户在说明后同意。

不要为每个实现计划自动触发。

### 不要触发

- 只读任务（审查、分析、解释、仅规划）。
- 不需要分支隔离的小范围编辑。
- 当前工作区干净且不需要并行工作的情况。
- 用户偏好留在当前工作区的情况。

## 创建前获取用户同意（强制）

在任何 `git worktree add` 之前，先说明必要性并请求确认。

使用这个格式：

```
我建议为这个任务创建 git worktree，因为<具体原因>。
这会增加设置成本（目录设置、可选依赖安装、可选基线检查）。
现在要创建吗？
```

如果用户没有明确批准，不要创建 worktree。

## 目录选择流程

按以下优先级执行：

### 1. 检查现有目录

```bash
# 按优先级检查
ls -d .worktrees 2>/dev/null     # 首选（隐藏目录）
ls -d worktrees 2>/dev/null      # 备选
```

**如果找到：** 使用该目录。如果两者都存在，优先使用 `.worktrees`。

### 2. 检查 CLAUDE.md

```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

**如果指定了偏好：** 直接使用，不需要再询问。

### 3. 询问用户

如果不存在目录，并且 CLAUDE.md 中也没有偏好：

```
没有找到 worktree 目录。应该在哪里创建 worktree？

1. .worktrees/（项目本地，隐藏目录）
2. ~/.config/superpowers/worktrees/<project-name>/（全局位置）

你倾向哪一个？
```

## 安全验证

### 对项目本地目录（.worktrees 或 worktrees）

**创建 worktree 前必须确认目录已被忽略：**

```bash
# 检查目录是否已被忽略（遵循本地、全局和系统 gitignore）
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果没有被忽略：**

遵循 Jesse 的规则“立即修复坏掉的东西”：
1. 向 .gitignore 添加合适的行
2. 提交该改动
3. 继续创建 worktree

**为什么重要：** 防止意外把 worktree 内容提交到仓库。

### 对全局目录（~/.config/superpowers/worktrees）

不需要 .gitignore 验证，因为它完全位于项目之外。

## 创建步骤（用户批准后）

### 1. 检测项目名

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
```

### 2. 创建 Worktree

```bash
# 确定完整路径
case $LOCATION in
  .worktrees|worktrees)
    path="$LOCATION/$BRANCH_NAME"
    ;;
  ~/.config/superpowers/worktrees/*)
    path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"
    ;;
esac

# 使用新分支创建 worktree
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

### 3. 运行项目设置（默认最小化）

默认采用最小设置。只有在用户要求时，或者下一个已确认任务马上需要时，才运行依赖安装。

需要时自动检测命令：

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

### 4. 验证基线（按需）

不要自动运行完整基线测试。先提议进行基线验证，并且只在用户确认后运行，除非上层工作流强制要求。

获得批准后，运行适合项目的命令：

```bash
# 示例：使用适合项目的命令
npm test
cargo test
pytest
go test ./...
```

**如果测试失败：** 报告失败内容，并询问是继续还是排查。

**如果测试通过：** 报告已准备好。

### 5. 报告位置

```
Worktree 已就绪：<full-path>
测试通过（<N> 个测试，0 个失败）
可以开始实现 <feature-name>
```

## 快速参考

| 情况 | 动作 |
|-----------|--------|
| `.worktrees/` 存在 | 使用它（验证已忽略） |
| `worktrees/` 存在 | 使用它（验证已忽略） |
| 两者都存在 | 使用 `.worktrees/` |
| 两者都不存在 | 检查 CLAUDE.md → 询问用户 |
| 目录未被忽略 | 添加到 .gitignore + 提交 |
| Worktree 未被明确批准 | 不创建；继续在当前工作区工作 |
| 设置/测试成本看起来很高 | 说明成本并在运行前询问 |
| 基线测试失败 | 报告失败 + 询问 |
| 没有 package.json/Cargo.toml | 跳过依赖安装 |

## 常见错误

### 跳过忽略验证

- **问题：** Worktree 内容被跟踪，污染 git status
- **修复：** 创建项目本地 worktree 前，始终使用 `git check-ignore`

### 假设目录位置

- **问题：** 造成不一致，违反项目约定
- **修复：** 遵循优先级：现有目录 > CLAUDE.md > 询问

### 测试失败后继续推进

- **问题：** 无法区分新 bug 和既有问题
- **修复：** 报告失败，并获得继续推进的明确许可

### 未经同意创建 worktree

- **问题：** 增加不必要的成本，并且可能违背用户偏好
- **修复：** 说明为什么需要隔离，然后先获得明确批准

### 硬编码设置命令

- **问题：** 在使用不同工具的项目中失效
- **修复：** 从项目文件自动检测（package.json 等）

## 示例工作流

```
你：我正在使用 using-git-worktrees 技能来设置隔离工作区。

[检查 .worktrees/ - 存在]
[验证已忽略 - git check-ignore 确认 .worktrees/ 已被忽略]
[创建 worktree：git worktree add .worktrees/auth -b feature/auth]
[运行 npm install]
[运行 npm test - 47 个测试通过]

Worktree 已就绪：/Users/jesse/myproject/.worktrees/auth
测试通过（47 个测试，0 个失败）
可以开始实现 auth 功能
```

## 危险信号

**绝不：**
- 在未验证已被忽略的情况下创建 worktree（项目本地）
- 在没有用户明确批准的情况下创建 worktree
- 跳过基线测试验证
- 在测试失败时不询问就继续推进
- 在目录位置有歧义时自行假设
- 跳过 CLAUDE.md 检查

**始终：**
- 先检查触发条件；不需要隔离时跳过
- 说明必要性和成本，然后在创建前请求同意
- 遵循目录优先级：现有目录 > CLAUDE.md > 询问
- 对项目本地目录验证其已被忽略
- 仅在需要/已批准时运行设置和基线验证

## 集成

**调用方：**
- **brainstorming**（Phase 4）- 当已批准的设计需要隔离实现时，可选使用
- **executing-plans** - 当计划表明隔离有收益时，可选使用
- 任何在用户同意后需要隔离工作区的技能

**配合：**
- **finishing-a-development-branch** - 工作完成后必须用于清理
