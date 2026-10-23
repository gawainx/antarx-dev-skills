# Codex Installation

Install and manage skills with the official CLI:

```bash
npx skills add gawainx/antarx-dev-skills -g -a codex
npx skills list -g -a codex
npx skills update requirement-clarification -g
npx skills remove requirement-clarification -g -a codex
```

Select the skills you need during installation. Omit `-g` to install in the current project. The CLI manages installed skills; they are not linked to this repository's sources.

DESIGN and AGENTS are separate global file configurations. Explicitly install them when needed by following the [README](../README.md#global-codex-and-claude-files). `scripts/sync_to_local.sh` and `scripts/doctor.sh` do not install, update, remove, or check skills.
