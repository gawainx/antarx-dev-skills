---
name: using-git-worktrees
description: Use when the user requests a worktree, or parallel implementation or a dirty workspace genuinely requires isolation. Do not trigger for read-only analysis or small changes that need no isolation. Proceed directly when creation is already authorized.
---

# Using Git Worktrees

## 1. Assess isolation needs and authorization

Inspect the current task, workspace status, and `git worktree list --porcelain`. Propose isolation only when independent implementations would compete for the same working tree, or new edits cannot be reliably separated from existing changes. Proceed directly if the user has requested a worktree or approved a plan that includes one; otherwise explain the specific reason and request confirmation once.

## 2. Choose a directory and branch

Prefer the user-specified path, then applicable AGENTS.md, CLAUDE.md, or project configuration, then existing `.worktrees/` or `worktrees/` directories. If none is specified, use `.worktrees/`. The user's location takes precedence over defaults.

Before creation, use `git check-ignore` on the actual selected in-repository worktree path. If it is not ignored, add the corresponding `.gitignore` rule and commit according to repository requirements. Paths outside the repository need no ignore rule. Check whether the target directory or branch already exists or is used by another worktree; do not overwrite existing work.

## 3. Create and prepare the workspace

Choose a branch name according to user or repository conventions, defaulting to the `codex/` prefix. For a new branch, use `git worktree add -b <branch> <path>`; for an existing branch, use `git worktree add <path> <branch>`. Append the user's specified starting ref when provided; otherwise use the confirmed task starting point.

Install dependencies only when the next step requires them. Derive commands from project documentation, lockfiles, and the actual package manager; do not guess from a single configuration file. Run relevant baseline checks according to task risk, without always running the full suite or repeatedly asking about routine validation within the authorized scope.

If baseline checks fail, determine whether the failure is pre-existing and whether it blocks this task. Record unrelated failures and continue independent work. Ask the user only when a failure prevents progress or requires a new decision.

## 4. Validate and hand off

Use `git worktree list --porcelain` and `git status --short --branch` in the new worktree to verify its path, branch, and state. Report preparation and validation actually performed; do not claim tests passed if none were run.

Hand off the new path, branch, and known blockers. Handle subsequent merging or deletion according to the user's request; do not require another completion skill.
