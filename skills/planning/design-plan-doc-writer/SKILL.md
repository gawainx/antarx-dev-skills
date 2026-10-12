---
name: design-plan-doc-writer
description: After requirements are clarified, write the requested design document or development plan in the corresponding sections of the same requirement document. Prefer saving through the DEVONthink skill; use docs at the project root only when MCP is not installed or enabled.
---

# Design and Development Plan Writing

Write documents only when requirement boundaries, constraints, and scope are stable.

## Inputs and deliverables

Reuse established requirements, designs, and user decisions without reconfirming them. If the user requests only a design, write only the design; if only a plan, build it from the existing design; if both, write the design before the plan. Resolve missing design decisions that affect the plan first, without requiring a new design document merely to complete a process.

## Choose a save location

- Use the current environment's tool discovery mechanism to check whether DEVONthink MCP is available.
- When available, read and invoke `$dt-writing-project-documents` to save this skill's output, following that skill's procedure.
- Save to `docs/` at the current project root only when MCP is not installed or enabled.

For local storage, use `<project-root>/docs/r001-short-title.md`, creating the directory if needed. After saving, verify the new content and preserved sections, and provide the file path to the user.

## Workflow

1. Confirm that requirement clarification is complete; otherwise continue clarification.
2. Locate and read the current requirement document using the save-location rules, and inspect relevant code and project constraints. By default, maintain requirement clarification, design, and development plan in the same document.
3. When reading historical documents, prioritize the current feature's goals, scope, and success criteria. Do not directly adopt historical boundaries as constraints on the new feature's design or plan, or give them first priority.
4. If the current feature conflicts with historical constraints, ask the user to resolve the tradeoff before writing those constraints into the design or development plan.
5. Check requirement IDs, titles, and content for an existing matching requirement; do not create a new file just because the stage has changed.
6. For a new requirement, increment the largest existing project requirement ID. Start at `r001` if none exist, using at least three digits. Reuse existing requirement IDs; do not renumber automatically.
7. If a matching requirement exists, compare scope and content first. Apply an explicitly requested update directly; ask only if the target or replacement scope is ambiguous.
8. Update the requested level-two "Design Document" and "Development Plan" sections in the same document, preserving existing clarification and unrelated content. Link the plan to the design section in that document.
9. Control scope strictly, explicitly identifying what is included and excluded.

## Output rules

- Follow the user's language; default to Simplified Chinese.
- Default to `r001-short-title.md`, with the requirement ID and name in the level-one heading and no date in the filename or title. Dates may appear at the beginning of the document. Explicit user naming takes precedence.
- Keep requirement clarification, design, and development plan in one file by default, separated by level-two headings. The local path is `<project-root>/docs/r001-short-title.md`; reuse the established document in later stages.
- Check and reuse existing project IDs and documents first. Confirm scope before migrating names or consolidating old documents, preserving original files and unrelated content. Existing separate directories do not justify creating more separate files.
- Update task status in the same document's plan section during development. Mark the requirement complete only after user acceptance; do not automatically move it to another directory or group.
- Use task statuses consistently: `Designed | Coding | Testing | Finished`.
- Use the English term `Stage` for development plan stages; do not use `Phase`.
- Cover only the scope confirmed for this round; do not silently expand it.
- Treat historical requirements, designs, and execution plans as background evidence only. Do not directly turn old exclusions such as "out of scope," "not implemented yet," or "no new dependencies" into restrictions on the current feature.

## Design document structure

Under `## Design Document` in the same requirement document, organize as needed:

1. `### Core Features (WHAT)`
2. `#### Background (WHY)`
3. `#### Goals (GOAL)`
4. `#### Scope Boundaries`
5. `### Implementation Flow (HOW)`
6. `### i18n` (omit when irrelevant)
7. `### Test Cases`

### Design requirements

- Explain the current architecture and final technical decisions.
- Identify integration points, state ownership, and key constraints.
- Derive key constraints from confirmed current requirements, current architectural facts, or explicit user decisions. Obtain user confirmation before applying a historical constraint that affects the new feature's scope.
- For UI work, describe layout structure, toolbar ownership, width strategy, empty states, and stability strategy.
- For internationalization, include keys, placeholders, language mappings, fallback strategy, and affected areas in `i18n`.
- Separate build checks, manual checks, and regression checks.

## Development plan structure

Under `## Development Plan` in the same requirement document, link to the design section first, then organize by Stage and task.

### Task template

Each task must include:

- `### Stage #N: [Stage name]`
- `#### Task #N: [Task name]`
- `**Status:** Designed | Coding | Testing | Finished`
- `**Files:** Create/Modify/Verify`, listing affected files
- Functionality / implementation notes / expected validation results: record the functions, behavior to implement, and expected outcomes for each task.

### Plan requirements

- Include at least one Stage, with at least one task per Stage.
- Make every task verifiable; a duration of 15-90 minutes is recommended.
- Use risk-driven validation: high-risk changes require stronger automation or migration checks.
- Add a final integrated validation task covering build/regression checks and plan status updates.
- Make one atomic commit after completing each Stage.

## Existing documents

- No matching requirement: create one requirement document at the established location, containing only sections authorized for this round.
- Matching requirement: update relevant sections in the same document, preserve unrelated content, and ask only about material ambiguity in the target or consolidation scope.

## References

- See `references/framework.md`.
- See `assets/r001-inspector-panel.md` for a single-document example. Its example ID is not a fixed ID for new requirements.
