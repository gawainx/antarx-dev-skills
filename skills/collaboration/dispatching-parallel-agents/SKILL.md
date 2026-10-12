---
name: dispatching-parallel-agents
description: Use when two or more tasks are independent, share no state, and have no sequential dependencies, to dispatch subagents in parallel for troubleshooting and implementation.
---

# Dispatching Parallel Agents

## Core principle

Assign one agent to each independent problem domain, work concurrently, and integrate the results afterward.

## When to use

- Failures span different test files or subsystems with clearly independent root causes.
- Each problem can progress without findings from the others.
- Agents will not compete for the same state or edit surface.

Do not use when:

- Problems are closely related, so fixing one may affect another.
- A global understanding of the system must come first.
- File conflicts or interference with shared resources would occur.

## Execution pattern

1. Group work by problem domain: files, subsystems, or error clusters.
2. Give each agent one clear goal and explicit constraints.
3. Dispatch agents in parallel.
4. Review returned results for conflicts, validate the complete result, and integrate.

## Task prompt requirements

- Focus: assign only one problem domain.
- Self-contained context: provide sufficient context, errors, and test names.
- Explicit constraints: specify whether production code may change or only tests.
- Explicit output: require root cause, change summary, and validation results.

## Common mistakes

- Overly broad tasks that let agents lose focus.
- Asking only to "fix the race" without location details.
- Missing constraints that lead to broad refactoring.
- Skipping final integrated validation.

## Validation loop

1. Review each agent's summary.
2. Check for conflicting edits and coverage gaps.
3. Run the full suite or targeted regression checks.
4. Spot-check for systematic incorrect fixes.
