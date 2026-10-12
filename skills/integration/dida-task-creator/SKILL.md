---
name: dida-task-creator
description: Create Dida tasks with the local dida CLI. Use when the user's prompt mentions both Dida and creating a task, or explicitly asks Codex to create a Dida task from the current project and conversation context.
---

Use the local `dida` command to create a task in the Dida project matching the current code project. Infer the Dida project name from repository context, create that project if it does not exist, then create a task with `title`, `desc`, and `tags`.

## Workflow

1. Confirm the request is in scope.
   - Continue only when the user's prompt mentions both Dida (滴答清单) and creating a task (创建任务), or the user explicitly invokes this skill.
   - Create one task by default, unless the user explicitly requests multiple tasks.
   - Assume `dida` is installed and authenticated. If the command fails due to missing authentication, stop and report the login issue.

2. Infer the code project name dynamically.
   - Inspect the current folder, repository root, local documentation, and source metadata as appropriate for the project.
   - Relevant signals include `AGENTS.md`, README, `package.json`, `pyproject.toml`, `Cargo.toml`, `Package.swift`, Xcode project/workspace names, the Git root directory name, and the current directory name.
   - Prefer a project or package name explicitly declared in repository files over a generic parent directory name.
   - Choose the most reliable signal for the current repository.
   - Keep the name human-readable, since it will become the Dida project name if no matching project exists.

3. Find or create the Dida project.
   - Run `dida project list --json`.
   - Match projects against the inferred project name.
   - Try an exact name match first, then normalize case and common separators such as spaces, hyphens, and underscores.
   - If exact or normalized matching returns multiple projects, list their names and IDs and ask the user to choose. Do not select one yourself or create another project with the same name. If the user supplied a project ID, verify that project directly.
   - If no project matches, create one with `dida project create --name "<projectName>" --view-mode list --kind TASK --json`.

4. Prepare task fields.
   - `title`: Short, actionable, and specific enough to stand alone in a task list.
   - `desc`: Start with a brief natural-language summary, then add necessary context such as the current path, relevant files, user intent, or key conversation facts. Do not paste the full conversation or use Dida as long-form document storage. This field is required and must not be empty.
   - `tags`: Always include `codex` and a normalized project tag. Add a task-type tag only when the request clearly identifies one, such as `bug`, `docs`, `feature`, `refactor`, `test`, `chore`, or a module name. Do not duplicate tags such as the project name.

5. Create the task.
   - Use the matched or newly created project ID.
   - Separate tags with ASCII commas.
   - Prefer `--json` so the result can be verified: `dida task create --title "<title>" --project "<projectId>" --desc "<desc>" --tags "codex,<projectTag>,<typeTag>" --json`.

## Ambiguous creation results

If a project or task creation command times out, disconnects, or returns an incomplete result, do not retry immediately. First use read-only CLI queries to check the submitted project name, or the task title and description in the target project. Consult CLI help if the query command is unclear. Reuse the ID when exactly one record can be confirmed as the result of this attempt. Retry only after confirming that creation did not occur. If the outcome remains unclear or multiple candidates exist, describe the candidates and ask the user to decide, avoiding duplicates.

## Field rules

- Keep `title` shorter than the description; avoid vague titles such as `Update` or `Fix issue`.
- Keep `desc` concise and include context that helps the user remember why the task exists or where to resume.
- Normalize tags to short lowercase labels where possible. For scoped packages or nested names, choose the most recognizable project tag; do not duplicate the project name as a tag.
- Do not invent a task-type tag when the type is unclear; `codex` and the project tag are sufficient.

## Safety boundaries

- Do not create reminders, due dates, priorities, recurrence rules, parent/child tasks, or multiple tasks unless explicitly requested.
- Do not modify, delete, complete, or move existing Dida tasks.
- Do not expose tokens or account details in task descriptions.
- After successful creation, report the task ID and project name.
