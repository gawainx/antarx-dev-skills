# Skill Improvement AX Workflow

## Configuration

The installed skill directory must contain `.skill-improvement-ax.env`.

`scripts/sync_to_local.sh` writes this file during installation:

```bash
ANTARX_DEV_SKILLS_REPO=/absolute/path/to/antarx-dev-skills
```

Treat this as local machine state. Do not commit it to the source repository.

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

## Source Repo Resolution

Run:

```bash
<installed-skill>/scripts/resolve_source_repo.sh
```

If it fails, ask the user for the `antarx-dev-skills` clone path and repair `.skill-improvement-ax.env` in the installed skill directory. Normal failures mean the config file is missing, the repo moved, or the repo was deleted.

## Existing Skill Updates

For an existing skill:

1. Run `scripts/compare_skill_copies.sh <skill-name>`.
2. If local and source copies differ, stop and ask which side is authoritative.
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
cd "$ANTARX_DEV_SKILLS_REPO"
```

After editing, validate and sync:

```bash
./scripts/sync_to_local.sh --dry-run
./scripts/sync_to_local.sh
./scripts/doctor.sh
```

The sync step updates `~/.codex/skills`, rewrites the local `.skill-improvement-ax.env`, and maintains a managed shell rc block for `ANTARX_DEV_SKILLS_REPO`, `CODEX_SKILLS_DIR`, and `CODEX_AGENTS_FILE`. Pass `--codex-memory-dir <path>` when the install should also persist `CODEX_MEMORY_DIR`.

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
