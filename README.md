# antarx-dev-skills

Agent Skills for requirements clarification, design planning, development, and debugging. They work with tools such as Codex, Claude Code, and Grok Build. Install and manage skills with the [skills CLI](https://github.com/vercel-labs/skills). See the [Traditional Chinese README](README.zh-TW.md).

## Installation

```bash
npx skills add gawainx/antarx-dev-skills
```

Follow the prompts to choose skills and target agents. By default, skills are installed in the current project. Add `-g` to install them globally. For example, to install globally for Codex:

```bash
npx skills add gawainx/antarx-dev-skills -g -a codex
```

## Skills

| Skill | Purpose |
| --- | --- |
| [requirement-clarification](skills/planning/requirement-clarification/SKILL.md) | Clarify goals, scope, and acceptance criteria |
| [design-plan-doc-writer](skills/planning/design-plan-doc-writer/SKILL.md) | Write design documents and development plans from confirmed requirements |
| [using-git-worktrees](skills/git/using-git-worktrees/SKILL.md) | Create and prepare isolated worktrees |
| [merge-worktree-to-source-branch](skills/git/merge-worktree-to-source-branch/SKILL.md) | Fast-forward worktree changes into the source branch |
| [dispatching-parallel-agents](skills/collaboration/dispatching-parallel-agents/SKILL.md) | Delegate independent tasks to parallel agents |
| [systematic-debugging](skills/quality/systematic-debugging/SKILL.md) | Investigate causes from evidence and verify fixes |
| [ui-layout-discipline](skills/ui/ui-layout-discipline/SKILL.md) | Inspect and fix UI layouts |
| [swiftui-macos-settings-window-pattern](skills/ui/swiftui-macos-settings-window-pattern/SKILL.md) | Build settings windows for macOS apps with SwiftUI |
| [dida-task-creator](skills/integration/dida-task-creator/SKILL.md) | Create TickTick tasks with the local dida CLI |
| [writing-flavor-review](skills/writing/writing-flavor-review/SKILL.md) | Review prose for awkward or AI-like writing and suggest focused edits |

## Updating and Removing Skills

```bash
# List skills provided by this repository
npx skills add gawainx/antarx-dev-skills --list

# List globally installed skills
npx skills list -g

# Update or remove a specific global skill
npx skills update requirement-clarification -g
npx skills remove requirement-clarification -g
```

The CLI manages installation locations and records. After changing skill source files in this repository, use the CLI to update installed skills.

## Saving Project Documents

Requirements clarification, design, and development plans are normally kept in one document and expanded section by section. When the DEVONthink MCP is available, save the document with the `dt-writing-project-documents` skill from [awesome-devonthink](https://github.com/gawainx/awesome-devonthink/tree/master/using-dt-skills); that skill must be provided separately. If the MCP is not installed or enabled, save the document under the project root's `docs/` directory.

## Global Codex and Claude Files

This repository also provides [DESIGN.md](DESIGN.md) and [AGENTS.root.md](AGENTS.root.md) for optional, independent installation. `AGENTS.root.md` can be used as the source for both Codex's `AGENTS.md` and Claude Code's `CLAUDE.md`. Run these commands from the repository root:

```bash
# Preview or install DESIGN for Codex only
./scripts/sync_to_local.sh --dry-run
./scripts/sync_to_local.sh

# Install DESIGN and Codex AGENTS
./scripts/sync_to_local.sh --sync-agents

# Install DESIGN and Claude CLAUDE.md
./scripts/sync_to_local.sh --sync-claude

# Check DESIGN; add --check-agents or --check-claude to check those links too
./scripts/doctor.sh
```

These scripts only manage global files. See [.env.example](.env.example) for target path configuration. The scripts stop if an existing DESIGN file is not from this project. Replacing an existing AGENTS file requires `--sync-agents --force-agents`; replacing an existing CLAUDE.md requires `--sync-claude --force-claude`.

## Maintenance

Skill sources are under `skills/<category>/<skill-name>/`. See [AGENTS.md](AGENTS.md) for development conventions. Edit, commit, and push source files in this repository; users manage skill installation and updates with the CLI.
