---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, testing/verification strategy, docs they might need to check, and how to validate results. DRY. YAGNI. Practical, risk-driven verification.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Language rules:**
- Use Simplified Chinese when interacting with the user while creating the plan.
- Write the final development plan document primarily in Simplified Chinese.

**Context:**
- Preferred: run in a dedicated worktree for medium/large or high-risk changes.
- Allowed: run in the current workspace for small, low-risk changes.
- Use judgment based on change scope, migration risk, and cross-module impact.

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## Tech Stack Rules

- Always follow the project's actual technology stack first.
- If stack conventions are unclear, use user-preferred defaults where applicable (Python: `click`, `rich`, `loguru`, `uv`).
- Never override explicit project constraints or existing conventions.

## Task Granularity

- Tasks should be independently verifiable and reasonably scoped.
- Typical task size is 15-90 minutes depending on complexity and risk.
- Do not force full RED-GREEN-REFACTOR for every task.
- Require a minimal verification strategy per task, scaled by risk.

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Related Design Doc:** [Exact path to approved design doc]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Scope / Out of Scope:** [Explicit boundaries]

---
```

## Task Structure

````markdown
## Phase #N: [Phase Name]

### Task #N: [Component Name]

**Status:** Desinged | Coding | Finished

**Files:**
- Create: `exact/path/to/new.file` (if needed)
- Modify: `exact/path/to/existing.file`
- Verify: `exact/path/to/tests/or/manual-checklist` (if applicable)

- Function: [What this task delivers]
- Implementation Notes: [Key technical decisions and constraints]
- Expected Verification Result: [What must pass or be observed]
- Completed At: [Optional timestamp when finished]
````

## Plan Management Requirements

- The plan MUST be organized into one or more phases (`Phase #1`, `Phase #2`, ...).
- Each phase MUST contain one or more tasks (`Task #1`, `Task #2`, ...).
- Every task MUST include:
  - Task content
  - Implementation notes
  - Expected result
  - Status: `Desinged | Coding | Finished`
- Verification must be risk-driven:
  - High-risk changes (schema migration, cross-module refactor, data sync): require stronger verification (automated tests and/or migration checks).
  - Medium/low-risk changes: allow targeted build checks plus key manual-path verification.
- Update task status promptly as work progresses.

## Remember
- Exact file paths always
- Include concrete implementation notes, not vague statements
- Include exact verification commands/checklists with expected outcomes when applicable
- Use Simplified Chinese as the primary language for any saved plan document
- Reference relevant skills with @ syntax
- DRY, YAGNI, practical verification, clear scope boundaries

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Stay in this session
- Fresh subagent per task + code review

**If Parallel Session chosen:**
- Guide them to open new session in worktree
- **REQUIRED SUB-SKILL:** New session uses superpowers:executing-plans
