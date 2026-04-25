---
name: merge-worktree-to-source-branch
description: Use when the user asks to 回合根源分支, 合回根源分支, 合并回主分支, 回到真正代码目录, merge a temporary worktree branch back to its source/root branch, or otherwise integrate worktree changes into the main code directory.
---

# Merge Worktree To Source Branch

## Hard Rule

When the current directory is a temporary worktree and the user asks to merge back to the source/root/main branch, do not switch the current temporary worktree to the target branch. The merge must be performed in the real code directory or in the worktree that already owns the target branch.

## Trigger Phrases

Use this skill for requests containing any equivalent of:

- 回合根源分支
- 合回根源分支
- 合并回主分支
- 回到真正代码目录
- merge this worktree back
- merge the worktree branch into the source branch
- integrate this worktree into the main/root/source branch

## Required Workflow

1. Inspect worktrees and branches without changing state:
   - `git worktree list --porcelain`
   - `git status --short --branch`
   - `git branch --show-current`
2. Identify:
   - current temporary worktree path;
   - source branch to merge from;
   - target/root branch;
   - real code directory or target branch worktree path.
3. Confirm the current temporary worktree is clean before merging.
4. Change `workdir` to the real code directory or the worktree that already has the target branch checked out.
5. In the target directory, verify:
   - `git status --short --branch` is clean;
   - `git branch --show-current` equals the target branch.
6. If the target branch is not checked out in that directory, switch there only after confirming the directory is the real code directory or target worktree. Never switch the temporary source worktree to the target branch.
7. Merge from the source branch in the target directory:
   - `git merge <source-branch>`
8. After merge, verify:
   - `git status --short --branch`
   - `git log --oneline --decorate -5`
9. Report the target directory, target branch, source branch, merge result, and current cleanliness.

## Stop Conditions

Stop and ask the user instead of guessing when:

- the real code directory cannot be identified from `git worktree list --porcelain`;
- the target/root branch is ambiguous;
- the target directory has uncommitted changes;
- the source worktree has uncommitted changes;
- the target branch is already checked out by another worktree and no safe target directory is clear;
- a merge conflict occurs.

## Correct Command Placement

Source worktree commands are only for inspection and source branch commits.

Target merge commands must run with `workdir` set to the real code directory or target branch worktree path.

Do not run these in the temporary source worktree:

- `git switch <target-branch>`
- `git checkout <target-branch>`
- `git merge <source-branch>` when the current branch is still the source branch

## Minimal User-Facing Summary Before Acting

Before performing the merge, state:

- Source branch: `<source-branch>` at `<source-worktree-path>`
- Target branch: `<target-branch>` at `<target-directory>`
- Action: merge source into target in the target directory

Then execute only that plan.
