---
name: skill-improvement-ax
description: Use when Codex should capture, improve, or backfill reusable workflow knowledge into the antarx-dev-skills repository from any project session. Triggers include requests to “沉淀技能”, “改良技能”, “同步回技能仓库”, “把这个流程做成 skill”, or update an existing Codex skill while also syncing the local installed skill and opening a GitHub PR.
---

# Skill Improvement AX

Use this skill to improve managed Codex skills from the current project context without switching sessions.

## Required Order

1. Clarify before writing anything.
2. Separate reusable workflow knowledge from project-specific information.
3. Resolve the source repository with `scripts/resolve_source_repo.sh`.
4. Inspect the target skill in the source repo and installed local copy.
5. Present the intended patch scope and get user confirmation.
6. Edit the source repo first.
7. Run source repo validation and `scripts/sync_to_local.sh`.
8. Create a non-protected branch, commit, push, and open a PR with `gh`.

## Guardrails

- Do not write current project business content, private paths, customer data, secrets, or internal implementation details into a skill.
- Existing skills are updated in place with patches. Do not overwrite or recreate an existing skill directory.
- If the source repo copy and local installed copy differ, stop and ask which side is authoritative.
- Never commit directly to `master`, `main`, `dev`, or other long-lived integration branches.
- Run `git worktree list` before any branch-changing operation.
- Use Conventional Commits and never use `git commit --amend`.
- Prefer `gh` for PR creation; use the GitHub connector only if `gh` is unavailable or fails.

## Resources

- Read `references/workflow.md` for the full clarification, writeback, sync, Git, and PR workflow.
- Use `scripts/resolve_source_repo.sh` to read `.skill-improvement-ax.env` and validate the source repo.
- Use `scripts/compare_skill_copies.sh <skill-name>` before editing an existing skill.
- Use `assets/clarification-template.md` to structure the pre-write clarification.
- Use `assets/pr-body-template.md` when creating the PR body.
