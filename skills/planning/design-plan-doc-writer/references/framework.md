# Design and Development Plan Writing Framework

## Trigger

Use after requirement clarification is complete and the user explicitly requests a design, a development plan, or both. Requirement exploration alone, implementation-only tasks, and conversation summaries do not trigger document writing.

## Document organization and storage

- Follow `SKILL.md` for save locations and tool entry points.
- Default to one `r001-short-title.md` per requirement, with level-two headings for "Requirement Clarification," "Design Document," and "Development Plan." Write only the requested sections in this round; do not expand scope to fill the structure.
- For new requirements, increment the project's largest requirement ID. Reuse the ID and record for existing requirements. Keep IDs consistent in titles and references; do not assign a new ID for each writing stage.
- Read the existing requirement document and adjacent implementation before adding a design or plan. Link the plan to the design section in the same document; for references to other documents, use actual file locations or DEVONthink URLs.
- Consolidating existing separate files requires a clear target and scope. Do not migrate, delete, renumber, or create copies without authorization. Reuse the established requirement document in later stages.
- Update plan status in the same document during development. Mark the requirement complete after user acceptance; do not automatically move the document.

## Writing checklist

1. Current scope and success criteria are clear; historical exclusions do not automatically restrict the current requirement.
2. The design identifies the actual architecture, state ownership, module integration points, and confirmed technical decisions.
3. For UI work, explain layout structure, empty states, widths, and stability. For internationalization, include keys, placeholders, language mappings, and fallback strategy.
4. Test cases describe expected behavior and appropriate verification, without accumulating a development activity log.
5. Divide the plan into Stages by dependency, subdividing into tasks when needed. Use consistent statuses: `Designed | Coding | Testing | Finished`.
6. Each task records Create/Modify/Verify files, implementation details, and expected validation results. The final task includes integrated validation and plan status updates.
7. Make one atomic commit after completing each Stage.
