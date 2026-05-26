---
name: workflow-review-packager
description: 回顾近期 Codex 工作、memory notes、rollout summaries、可选 Chronicle discovery，以及现有 skills、custom agents 和 automations，识别值得封装的重复手工 workflow。Use when the user asks for “复盘”, “回顾”, “review”, “look back”, “retrospective”, or similar wording to find reusable workflow opportunities, create high-confidence missing skills, custom subagents, or automations, or decide whether to extend existing assets instead of duplicating them.
---

# Workflow Review Packager

## Overview

Use this skill to find repeated manual work that is worth turning into a reusable asset. Prefer narrow, evidence-backed packaging over speculative or broad assets.

## Time Range

Bind the review window to the time range the user mentions. If the user does not specify a time range, default to the last 30 days, or all available history if less than 30 days is available.

## Evidence Order

Use available evidence in this order:

1. Recent Codex sessions and task summaries.
2. Codex Memories and rollout summaries that show patterns repeated across sessions.
3. Chronicle, if enabled, for discovery only. Confirm important details in the relevant source system when possible.
4. Existing skills, custom agents, and automations, so you reuse or extend what already exists.

## Candidate Criteria

Look broadly across coding, research, writing, planning, communication, operations, analysis, and personal administration. Act on a candidate only when it:

- Occurred at least twice, or is clearly likely to recur and costly to repeat.
- Has stable inputs, a repeatable procedure, and a clear output or stopping condition.
- Would materially improve speed, quality, consistency, or reliability.
- Is not already adequately covered by an existing asset.

## Choose The Smallest Form

Choose the smallest appropriate form:

- Skill: a reusable workflow or playbook.
- Custom subagent: a bounded specialist role or investigation task suitable for delegation.
- Automation: a scheduled or recurring check, report, reminder, or monitor.
- Extend existing: an existing skill, agent, or automation already covers most of the need.
- Skip: the work is too one-off, ambiguous, sensitive, poorly evidenced, or already covered.

## Workflow

1. Produce a compact shortlist before creating anything.
2. Include each repeated workflow, supporting evidence and dates, frequency or confidence, recommended form, and why it is or is not worth creating.
3. Create or extend only high-confidence missing items.
4. Keep created assets narrow, practical, source-aware, and easy to validate.
5. Do not create speculative, overlapping, or overly broad assets.

## Shortlist Format

Use this compact format:

```markdown
## Shortlist

### <candidate name>
- Repeated workflow:
- Evidence and dates:
- Frequency/confidence:
- Recommended form:
- Worth creating:
```

## Creation Rules

- For a new skill, use `skill-creator` or the repository's established skill creation workflow.
- For an existing skill, patch it in place and keep project-specific or sensitive details out.
- For a custom subagent, keep the role bounded and define inputs, procedure, and output.
- For an automation, use the app's automation tool rather than hand-written schedules.
- For skipped candidates, record the evidence gap instead of creating a placeholder asset.

## Finish

End with:

- What you created or extended.
- What you deliberately skipped.
- What needs more evidence before packaging.
