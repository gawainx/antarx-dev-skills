---
name: dida-task-creator
description: Create Dida/TickTick tasks with the local dida CLI. Use when the user prompt simultaneously mentions "滴答清单" and "创建任务", or explicitly asks Codex to create a Dida task from the current project and conversation context.
---

# Dida Task Creator

## Overview

Use the local `dida` command to create one task in the Dida project that matches the current code project. Infer the Dida project name from the repository context, create the Dida project when missing, then create a task with `title`, `desc`, and `tags`.

## Workflow

1. Confirm the request is in scope.
   - Proceed only when the prompt mentions both `滴答清单` and `创建任务`, or the user explicitly invokes this skill.
   - Create one task unless the user explicitly asks for multiple tasks.
   - Assume `dida` is installed and authenticated. If a `dida` command fails because authentication is missing, stop and report the login issue.

2. Infer the code project name dynamically.
   - Inspect the current folder, repository root, local instructions, and source metadata as appropriate for the project.
   - Useful signals include `AGENTS.md`, README files, `package.json`, `pyproject.toml`, `Cargo.toml`, `Package.swift`, Xcode project/workspace names, git root name, and the current directory name.
   - Prefer an explicit project or package name from repository files over a generic parent directory.
   - Do not hard-code a single language, manifest file, or rigid extraction function; choose the best signal for the current repository.
   - Keep the chosen project name human-readable because it will be used as the Dida project name when a project must be created.

3. Find or create the Dida project.
   - Run `dida project list --json`.
   - Match the Dida project using the inferred project name.
   - First try exact name matching. If that fails, try normalized matching that ignores case and common separators such as spaces, hyphens, and underscores.
   - If no project matches, create one with:

```bash
dida project create --name "<projectName>" --view-mode list --kind TASK --json
```

4. Compose task fields.
   - `title`: concise, actionable, and specific enough to stand alone in a task list.
   - `desc`: write a short natural-language summary, then append only necessary context such as current path, relevant files, user intent, or key conversation facts. Do not paste the full conversation or turn Dida into a long-form document store.
   - `tags`: always include `codex`; add a normalized project tag; add a task-type tag when it is clear from the request, such as `bug`, `docs`, `feature`, `refactor`, `test`, `chore`, or another concise domain tag.

5. Create the task.
   - Use the matched or newly created project id.
   - Pass tags as a comma-separated list.
   - Prefer `--json` so the result can be verified.

```bash
dida task create --title "<title>" --project "<projectId>" --desc "<desc>" --tags "codex,<projectTag>,<typeTag>" --json
```

## Field Guidelines

- Keep `title` shorter than the description and avoid vague titles such as `Update` or `Fix issue`.
- Keep `desc` brief. Include context only when it helps the user remember why the task exists or where to continue.
- Normalize tags to short lowercase labels when practical. For scoped packages or nested names, choose the most recognizable project label.
- If the task type is ambiguous, omit the type tag instead of inventing one; `codex` and the project tag are enough.

## Safety

- Do not create reminders, due dates, priorities, repeats, parent tasks, or multiple tasks unless the user explicitly asks.
- Do not modify, delete, complete, or move existing Dida tasks.
- Do not expose tokens or account details in task descriptions.
- Report the created task id and project name after successful creation.
