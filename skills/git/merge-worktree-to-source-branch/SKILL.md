---
name: merge-worktree-to-source-branch
description: 当用户要求把临时 worktree 的改动合回源分支、根分支或主代码目录时使用；自动路径仅支持未被检出的目标分支的快进 ref 更新。
---

# 将 Worktree 合回源分支

## 操作边界

不切换任何既有 worktree 的分支。自动集成仅使用 `git fetch . <source-branch>:<target-branch>` 快进目标 ref；不执行 merge、rebase、force、创建 worktree 或推送。超出该路径时说明阻碍并提供手动方案，不绕过 Git 的分支占用保护。

## 检查与执行

1. 串行运行 `git worktree list --porcelain`、`git status --short --branch` 和 `git branch --show-current`，识别当前临时 worktree、源分支、目标分支及真实代码目录。目标不明确时先询问，不猜测主分支名。
2. 源 worktree 必须干净；两个分支使用 `git rev-parse --verify refs/heads/<branch>` 验证。相同分支不执行集成；两个分支已指向同一提交时报告无需更新。
3. 从 worktree 列表核对目标分支是否被任一 worktree 检出，包括当前 worktree。被占用时停止自动路径，指出占用目录；不得使用 `--update-head-ok` 或直接更新 ref 绕过保护。
4. 用 `git merge-base --is-ancestor <target-branch> <source-branch>` 判断能否快进。不能快进时停止自动路径，说明需要手动合并。
5. 说明源路径、源分支、目标分支和仅更新 ref 的动作。执行前再次核对分支占用与提交位置；状态变化时重新评估。
6. 执行 `git fetch . <source-branch>:<target-branch>`。失败时读取原因，不追加 force 或其他绕过参数重试。
7. 用 `git rev-parse` 核对两分支提交一致，并检查当前 worktree 状态。报告实际更新结果，不把 ref 更新描述为已刷新其他目录中的文件。

## 手动方案

目标分支已被检出时，给出进入对应目录、检查状态并合并源分支的命令供用户审阅，不执行。可快进时使用 `git merge --ff-only <source-branch>`；已分叉时说明需要常规合并及可能的冲突处理。

目标分支未被检出但已分叉时，可提供创建目标 worktree 后合并的手动方案。创建、切换、解决冲突或推送均不作为本技能的自动后续动作。
