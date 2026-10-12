---
name: merge-worktree-to-source-branch
description: Use when the user asks to integrate a temporary worktree's changes back into the source branch, root branch, or main code directory. Automatic integration supports only fast-forward ref updates to a target branch that is not checked out.
---

# Merge a Worktree Back to the Source Branch

## Operational boundaries

Do not switch branches in any existing worktree. Automatic integration only fast-forwards the target ref with `git fetch . <source-branch>:<target-branch>`; do not merge, rebase, force, create a worktree, or push. When this path is unavailable, explain the blocker and provide a manual procedure. Do not bypass Git's protection for checked-out branches.

## Checks and execution

1. Run `git worktree list --porcelain`, `git status --short --branch`, and `git branch --show-current` sequentially to identify the current temporary worktree, source branch, target branch, and actual code directory. Ask if the target is unclear; do not guess the main branch name.
2. Require a clean source worktree and verify both branches with `git rev-parse --verify refs/heads/<branch>`. Do not integrate a branch into itself. If both branches already point to the same commit, report that no update is needed.
3. Check the worktree list to see whether any worktree, including the current one, has the target branch checked out. If so, stop automatic integration and identify the directory using it. Do not use `--update-head-ok` or direct ref updates to bypass protection.
4. Check whether a fast-forward is possible with `git merge-base --is-ancestor <target-branch> <source-branch>`. If not, stop automatic integration and explain that a manual merge is required.
5. Describe the source path, source branch, target branch, and ref-only update. Recheck branch occupancy and commit positions immediately before execution; reassess if the state has changed.
6. Run `git fetch . <source-branch>:<target-branch>`. On failure, inspect the cause; do not retry with force or other bypass options.
7. Use `git rev-parse` to verify that both branches point to the same commit and inspect the current worktree status. Report the actual update; do not describe a ref update as refreshing files in other directories.

## Manual procedures

If the target branch is checked out, provide commands to enter its directory, inspect its status, and merge the source branch for the user to review; do not execute them. Use `git merge --ff-only <source-branch>` when a fast-forward is possible. If the branches have diverged, explain that a regular merge and potential conflict resolution are needed.

If the target branch is not checked out but has diverged, a manual procedure may create a target worktree and merge there. Creating worktrees, switching branches, resolving conflicts, and pushing are not automatic follow-up actions of this skill.
