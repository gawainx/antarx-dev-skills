---
name: merge-worktree-to-source-branch
description: 当用户要求“回合根源分支”“合回根源分支”“合并回主分支”“回到真正代码目录”，或要求把临时 worktree 分支合回源分支/根分支、把 worktree 改动集成回主代码目录时使用。
---

# 将 Worktree 合回源分支

## 硬规则

当当前目录是临时 worktree，且用户要求合回源分支、根分支或主分支时，绝不切换源 worktree、真实代码目录或任何既有 worktree 的分支。只有目标分支可以通过直接更新目标分支 ref 快进到源分支时，才允许自动集成。

自动集成时只能使用这种仅更新 ref 的快进形式：

```bash
git fetch . <source-branch>:<target-branch>
```

如果目标分支无法快进到源分支，停止并打印手动合并命令供用户审阅。不要运行 `git merge`，不要创建 worktree，也不要切换分支。

## 触发短语

请求中包含以下任意等价表达时使用本技能：

- 回合根源分支
- 合回根源分支
- 合并回主分支
- 回到真正代码目录
- merge this worktree back
- merge the worktree branch into the source branch
- integrate this worktree into the main/root/source branch

## 必需工作流

1. 在不改变状态的前提下检查 worktree 和分支：
   - `git worktree list --porcelain`
   - `git status --short --branch`
   - `git branch --show-current`
2. 识别：
   - 当前临时 worktree 路径；
   - 要合入来源的源分支；
   - 目标/根分支；
   - 真实代码目录；
   - 真实代码目录的当前分支。
3. 确认当前临时源 worktree 干净：
   - `git status --short --branch`
4. 在不改变 checkout 状态的前提下确认两个分支都存在：
   - `git rev-parse --verify <source-branch>`
   - `git rev-parse --verify <target-branch>`
5. 检查目标分支是否可以快进到源分支：
   - `git merge-base --is-ancestor <target-branch> <source-branch>`
6. 如果快进检查通过，说明动作并只更新目标分支 ref：
   - `git fetch . <source-branch>:<target-branch>`
7. 如果快进检查失败，停止并打印手动命令供用户审阅。不要执行它们：

   ```bash
   # 方案 A：使用已有目标分支 worktree
   cd <target-branch-worktree>
   git status --short --branch
   git merge <source-branch>

   # 方案 B：创建临时目标 worktree
   git worktree add <temporary-target-worktree> <target-branch>
   cd <temporary-target-worktree>
   git status --short --branch
   git merge <source-branch>
   ```

8. 仅更新 ref 的快进成功后，验证：
   - `git rev-parse <target-branch>`
   - `git rev-parse <source-branch>`
   - `git status --short --branch`
   - `git log --oneline --decorate -5`
9. 报告源分支、目标分支、目标 ref 更新结果，并说明没有切换任何 worktree 分支。

## 停止条件

遇到以下情况时停止并询问用户，不要猜测：

- 无法从 `git worktree list --porcelain` 识别真实代码目录；
- 目标/根分支存在歧义；
- 源 worktree 有未提交改动；
- 源分支或目标分支无法验证；
- 目标分支无法快进到源分支；
- 更新目标分支需要 force、rebase、创建 merge commit、解决冲突、切换分支或创建 worktree；
- 请求的动作需要推送到远端，但用户没有明确要求推送。

## 正确命令位置

源 worktree 中的命令只用于检查和源分支提交。

自动更新目标分支时必须使用仅更新 ref 的快进命令。这些命令可以从仓库中的任意干净 worktree 运行，因为它们只更新 ref，不改变当前 checkout。

自动路径中不要运行这些命令：

- `git switch <target-branch>`
- `git checkout <target-branch>`
- `git merge <source-branch>`
- `git worktree add <path> <target-branch>`
- `git push`

## 执行前给用户的最小摘要

执行快进 ref 更新前，说明：

- 源分支：`<source-branch>`，位于 `<source-worktree-path>`
- 目标分支：`<target-branch>`
- 真实代码目录当前分支：`<current-branch>`
- 动作：仅通过更新目标 ref，将 `<target-branch>` 快进到 `<source-branch>`
- 安全性：不会切换任何 worktree 分支

然后只执行这份计划。
