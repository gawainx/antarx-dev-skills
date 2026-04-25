---
name: merge-worktree-to-source-branch
description: Use when the user asks to 回合根源分支, 合回根源分支, 合并回主分支, 回到真正代码目录, merge a temporary worktree branch back to its source/root branch, or otherwise integrate worktree changes into the main code directory.
---

# Merge Worktree To Source Branch

## Hard Rule

When the current directory is a temporary worktree and the user asks to merge back to the source/root/main branch, never switch the branch of the source worktree, the real code directory, or any existing worktree. Automatic integration is allowed only when the target branch can be fast-forwarded to the source branch by updating the target branch ref directly.

Use this ref-only fast-forward form for automatic integration:

```bash
git fetch . <source-branch>:<target-branch>
```

If the target branch cannot be fast-forwarded to the source branch, stop and print manual merge commands for user review. Do not run `git merge`, create worktrees, or switch branches.

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
   - real code directory;
   - current branch of the real code directory.
3. Confirm the current temporary source worktree is clean:
   - `git status --short --branch`
4. Confirm both branches exist without changing checkout state:
   - `git rev-parse --verify <source-branch>`
   - `git rev-parse --verify <target-branch>`
5. Check whether the target branch can be fast-forwarded to the source branch:
   - `git merge-base --is-ancestor <target-branch> <source-branch>`
6. If the fast-forward check succeeds, state the action and update only the target branch ref:
   - `git fetch . <source-branch>:<target-branch>`
7. If the fast-forward check fails, stop and print manual commands for user review. Do not execute them:

   ```bash
   # Option A: use an existing target-branch worktree
   cd <target-branch-worktree>
   git status --short --branch
   git merge <source-branch>

   # Option B: create a temporary target worktree
   git worktree add <temporary-target-worktree> <target-branch>
   cd <temporary-target-worktree>
   git status --short --branch
   git merge <source-branch>
   ```

8. After a successful ref-only fast-forward update, verify:
   - `git rev-parse <target-branch>`
   - `git rev-parse <source-branch>`
   - `git status --short --branch`
   - `git log --oneline --decorate -5`
9. Report the source branch, target branch, target ref update result, and that no worktree branch was switched.

## Stop Conditions

Stop and ask the user instead of guessing when:

- the real code directory cannot be identified from `git worktree list --porcelain`;
- the target/root branch is ambiguous;
- the source worktree has uncommitted changes;
- either source or target branch cannot be verified;
- the target branch cannot be fast-forwarded to the source branch;
- updating the target branch would require force, rebase, merge commit creation, conflict resolution, branch switching, or worktree creation;
- the requested action requires pushing to a remote and the user has not explicitly requested that push.

## Correct Command Placement

Source worktree commands are only for inspection and source branch commits.

Automatic target updates must use ref-only fast-forward commands. They may run from any clean worktree in the repository because they update refs without changing the current checkout.

Do not run these during the automatic path:

- `git switch <target-branch>`
- `git checkout <target-branch>`
- `git merge <source-branch>`
- `git worktree add <path> <target-branch>`
- `git push`

## Minimal User-Facing Summary Before Acting

Before performing the fast-forward ref update, state:

- Source branch: `<source-branch>` at `<source-worktree-path>`
- Target branch: `<target-branch>`
- Real code directory current branch: `<current-branch>`
- Action: fast-forward `<target-branch>` to `<source-branch>` by updating the target ref only
- Safety: no worktree branch will be switched

Then execute only that plan.
