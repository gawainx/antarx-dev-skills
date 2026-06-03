---
name: obsidian-codex-memory-init
description: Initialize an Obsidian vault as a Codex cross-project long-term memory store. Use when the user asks to "初始化obsidian codex memory", "初始化 Obsidian Codex 记忆", "初始化记忆", or otherwise mentions both memory/记忆 and initialization/初始化 for Codex or Obsidian.
---

# Obsidian Codex Memory Init

Use this skill to initialize a user-specified Obsidian vault with a `CodexMemory` folder, memory rules, basic Markdown files, and a Codex global AGENTS.md pointer.

## Workflow

1. Ask the user for the Obsidian vault path if they did not provide it.
2. Validate the path before writing:
   - It must exist.
   - It must be a directory.
   - Prefer paths that contain `.obsidian/`, but do not require it if the user explicitly says the directory is the vault.
3. Run the initializer script from this installed skill:

```bash
python3 <skill-dir>/scripts/init_obsidian_codex_memory.py --vault-path "<vault-path>"
```

4. If the user provides a custom global AGENTS.md path, pass it with `--global-agents-path`; otherwise the script uses `CODEX_AGENTS_FILE` and falls back to `$HOME/.codex/AGENTS.md`.
5. Verify the script output and, when useful, confirm with `find <vault-path>/CodexMemory -maxdepth 2 -print` and `rg -n "Obsidian Codex 记忆|CodexMemory" <global-agents-path>`.
6. Report:
   - The created or existing memory files.
   - The global instruction file that was updated.
   - Any validation warning, such as missing `.obsidian/`.

## Defaults

- Memory directory name: `CodexMemory`
- Default global instruction file: `CODEX_AGENTS_FILE`, falling back to `$HOME/.codex/AGENTS.md`
- Initialization is idempotent: existing files are preserved, and the global Obsidian memory section is not duplicated.

## Safety Rules

- Do not save Cookie, Token, API Key, passwords, verification codes, ID numbers, bank cards, private contact info, third-party account secrets, or sensitive log values.
- Do not write full chat transcripts or temporary process logs into the memory store.
- Only initialize structure and durable rules during this workflow.
