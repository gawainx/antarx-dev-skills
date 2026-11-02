# Repository Guide

## Source and Style

- Maintain skill sources under `skills/<category>/<skill-name>/SKILL.md`, with supporting files in the same directory as needed. Do not edit skill installation directories directly. Keep reference materials and plans under `docs/`.
- Use lowercase, hyphen-separated skill directory names. Write skill content in concise, action-oriented English with explicit trigger conditions. Use English for skill names and the `display_name` in `openai.yaml`.
- Use Bash with `set -euo pipefail` for shell scripts. Prefer ASCII in files that do not contain Chinese text.

## Rules

- Keep Cursor rule sources only in the top-level `rules/` directory, with no subdirectories. Each rule is one `.mdc` file with a lowercase, hyphen-separated name.
- Write rules in concise English and state the trigger conditions. Include `description` and `alwaysApply` in the frontmatter, and add `globs` when the rule should trigger for matching files.
- Install rules with `npx rulesx add <source> --rule '*.mdc'`. This copies them into the target project's `.cursor/rules/`. `rulesx` only provides `add`; running it again overwrites same-named files in the target. Do not create links to this repository's sources, and do not edit the copies in the target project.
- Installation requires explicit user authorization for the current operation. First verify the target project and rule scope. Source maintenance, failed checks, and synchronization requirements in other documents do not constitute authorization. It is normal for rules not to be installed.
- Use `--rule '*.mdc'` when installing rules. `--rule '*'` also copies root-level agent files into the target project. This file must not be used as an installation source.

## Installation and Management

- Install, update, list, and remove all skills through `npx skills`. Let the CLI manage installation locations and records; do not create skill installation links pointing to this repository's sources.
- `scripts/sync_to_local.sh` and `scripts/doctor.sh` only install or check the global Codex DESIGN, Codex AGENTS, and Claude CLAUDE.md files. Their installation sources are `DESIGN.md` and `AGENTS.root.md`, respectively; the latter is the source for both Codex AGENTS and Claude CLAUDE.md. This file governs repository development only and must not be used as an installation source.
- Installation or updates require explicit user authorization for the current operation. First verify the scope and side effects, then process only the specified skills and targets. Source maintenance, failed checks, historical installation status, and automatic synchronization requirements in other documents do not constitute authorization. It is normal for a skill not to be installed.
- Do not additionally modify shell configuration or install or modify global AGENTS without explicit user authorization. When uninstalling, remove only installation entries and records whose origin has been confirmed. Check for leftovers and do not reinstall afterward.

## Completion Criteria

Verify the changes, formatting, and relevant references, then commit and successfully push to the remote before finishing.
