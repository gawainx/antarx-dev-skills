---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Language rules:**
- Use Simplified Chinese for execution updates, progress reports, and clarification questions with the user.
- Use Simplified Chinese as the primary language for any document saved during execution.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed
5. Confirm each selected task starts from `Desinged` and will transition through `Coding` to `Finished`

### Step 2: Execute Batch
**Default: Execute 1-3 tasks per batch, dynamically chosen by risk and coupling.**

For each task:
1. Mark status as `Coding`
2. Execute by task objective and boundaries
3. If execution needs deviation from the plan, record the deviation and confirm with the user before proceeding
4. Run risk-driven verifications as specified in the plan
5. Mark status as `Finished`

### Step 3: Report
When batch complete:
- Show what was implemented
- Show verification output
- Say: "Ready for feedback."

### Step 4: Continue
Based on feedback:
- Apply changes if needed
- Execute next batch
- Repeat until complete

### Step 5: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Verification Strategy

- Follow the same risk-driven verification policy defined by writing-plans.
- High-risk changes (schema migration, cross-module refactor, sync/data consistency): run stronger checks (automated tests and/or migration checks).
- Medium/low-risk changes: allow targeted build/test checks plus key manual-path verification.
- Always report verification command/checklist and outcome for the batch.

## Remember
- Review plan critically first
- Execute by task (not forced micro-steps)
- Follow plan goals and boundaries; confirm before deviating
- Use risk-driven verification; do not skip required checks
- Use Simplified Chinese as the primary language for saved execution records or related documents
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - Recommended for medium/large or high-risk changes; low-risk changes may run in current workspace
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
