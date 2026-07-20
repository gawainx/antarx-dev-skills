# Skill Improvement AX Workflow

## Source Repo Resolution

The installed `skill-improvement-ax` directory is a symlink to the source repository. `scripts/resolve_source_repo.sh` resolves the repository root from its own real path and validates that the result is an `antarx-dev-skills` checkout.

## Clarification

Before any write, clarify:

- Target skill name.
- Whether this is an update to an existing skill or a new skill.
- Trigger phrases and situations that should activate the skill.
- Reusable workflow rules to preserve.
- Project-specific details to exclude.
- Required scripts, references, or assets.
- Whether the user approves writing the source repo and syncing the local install.

Use `assets/clarification-template.md` for the response shape.

Run:

```bash
<installed-skill>/scripts/resolve_source_repo.sh
```

If it fails, run `./scripts/sync_to_local.sh` from the expected repository checkout and then retry. Normal failures mean the installed skill is not a symlink to the source repository, the repository moved, or the repository was deleted.

## Existing Skill Updates

For an existing skill:

1. Run `scripts/compare_skill_copies.sh <skill-name>`.
2. If the installed entry is missing or points somewhere else, run `./scripts/sync_to_local.sh` from the source repository and retry.
3. Read the source repo copy reported by `scripts/find_source_skill.sh <skill-name>`.
4. Patch only the needed files.
5. Preserve the skill structure. Keep long templates in `assets/`, deterministic operations in `scripts/`, and detailed guidance in `references/`.

For a new skill:

1. Create `skills/<category>/<skill-name>/SKILL.md`.
2. Add only required `assets/`, `scripts/`, or `references/`.
3. Keep frontmatter to `name` and `description`.
4. Keep the installed skill name stable; source categories are for repository organization only.

## Writeback And Sync

Write to the source repo first:

```bash
cd "$(<installed-skill>/scripts/resolve_source_repo.sh)"
```

After editing, validate and sync:

```bash
./scripts/sync_to_local.sh --dry-run
./scripts/sync_to_local.sh
./scripts/doctor.sh
```

The sync step updates managed skill symlinks for the selected agent targets and maintains a managed shell rc block for `ANTARX_DEV_SKILLS_REPO`, skill install roots, and `CODEX_AGENTS_FILE`.

## Git And PR

Before changing branches:

```bash
git status --short
git worktree list
```

If unrelated dirty files exist, stop and ask how to proceed.

Create a branch that is not `master`, `main`, or `dev`:

```bash
git switch -c codex/improve-<skill-name>-<short-desc>
```

Commit with a valid Conventional Commit message:

```bash
git commit -m "docs: improve <skill-name> workflow"
```

Push the branch and create a PR with `gh`:

```bash
git push -u origin codex/improve-<skill-name>-<short-desc>
gh pr create --title "docs: improve <skill-name> workflow" --body-file <pr-body-file>
```

Use `assets/pr-body-template.md` for PR content. Include changed paths, validation output, and privacy/safety notes.
