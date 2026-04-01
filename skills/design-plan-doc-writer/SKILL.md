---
name: design-plan-doc-writer
description: Draft repository-aligned design documents and phased development plans after requirements clarification is complete. Use when the user has finished or explicitly confirmed requirements clarification for a feature or refactor and then asks to write the corresponding design doc, development plan, or both. Apply this skill to follow the sequence "requirements clarification, then design doc, then development plan", produce paired docs under the repo's docs/ and plan/ conventions, preserve the user's language (default Simplified Chinese), and compare any same-prefix existing docs before asking whether to append or overwrite.
---

# Design Plan Doc Writer

Write the design doc and development plan only after requirements clarification is complete enough that implementation scope, constraints, and boundaries are stable. Treat the ordering as mandatory: requirements clarification first, design doc second, development plan third.

## Workflow

1. Confirm that requirements clarification is finished; if not, continue clarification instead of drafting docs.
2. Inspect the repository's existing `docs/`, `plan/`, and any feature-adjacent code before drafting.
3. Infer the documentation category from the feature domain.
4. Check whether a same-prefix document already exists.
5. If a same-prefix doc exists, read it, summarize the difference, and explicitly ask whether to append or overwrite before writing anything.
6. Draft the design doc first.
7. Draft the development plan second, and link the design doc in `## Related Design Doc`.
8. Keep scope tight. If the current session is only UI scaffolding or only planning, state what is explicitly out of scope.

## Output Rules

- Match the user's language. Default to Simplified Chinese when the conversation is Chinese or language is unspecified.
- Follow the fixed sequence `requirements clarification, then design doc, then development plan`; do not skip straight to the plan unless the user explicitly overrides this.
- Use `{Feat}_{YYYYMMDD}.md` naming.
- Put UI and UX topics under `docs/UI/` and `plan/UI/` when that categorization fits.
- Keep the design doc detailed enough that another agent can implement from it without re-discovery.
- Keep the plan task-oriented, grouped by phase, and record task status using `Designed | Coding | Testing | Finished`.
- Emphasize that each completed task should end with one git commit so implementation stays atomically traceable.
- Keep the plan focused on the current session scope. Do not silently expand into later business features.

## Design Doc Structure

Follow this structure unless the repository already has a stronger local convention for the same feature family:

1. Title line using the file name.
2. `## 核心功能`
3. `### 需求背景`
4. `### 需求目标`
5. `### 范围边界`
6. `## 实现流程`
7. `## i18n`
8. `## 测试用例`

### Design Expectations

- Explain current architecture and the decision taken after research.
- Separate in-scope and out-of-scope items explicitly.
- Include code touch points, state ownership, UI ownership, and layout or concurrency constraints when relevant.
- For UI work, document layout structure, toolbar ownership, width strategy, empty states, and stability rules.
- For future follow-up capabilities, capture only the pre-wiring or reserved interfaces if they are not in current scope.
- In `## i18n`, list proposed keys, placeholder rules, language mapping, fallback strategy, and impact scope.
- In `## 测试用例`, split compile checks, manual checks, and regression checks.

## Plan Structure

Follow this structure unless the repository already has a stronger local convention for the same feature family:

1. Title line using the file name.
2. `## Related Design Doc`
3. `## Phase`
4. `## Tasks`

### Plan Expectations

- Group tasks into 1 or more phases.
- Each task must have:
  - `[Task#N]` identifier
  - a concise function goal
  - implementation points
  - expected test result
  - status field using `Designed | Coding | Testing | Finished`
- Order tasks so the first phase establishes the shell or scaffolding before feature wiring.
- Add a final verification task for build/regression and plan state write-back.
- State that each finished task should be followed by a git commit to preserve atomic history.
- Keep deferred business features visible as later tasks only if they remain in the same agreed session scope; otherwise state them as out of scope in the design doc instead of inflating the plan.

## Existing-Doc Handling

Before creating a doc, inspect `docs/` and `plan/` for the same feature prefix.

- If no same-prefix doc exists, create the new files directly.
- If a same-prefix doc exists, read it first and compare scope, date, and content.
- Do not overwrite silently. Asking whether to append or overwrite is mandatory before any write.

## Resources

- Read [references/framework.md](references/framework.md) for the distilled drafting checklist and category/file-placement rules.
- Use the sample assets under `assets/` as concrete reference outputs when shaping new docs and plans.
