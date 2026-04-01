# Design And Plan Drafting Framework

## Trigger Pattern

Use this skill when:
- requirements clarification has finished or the user has explicitly confirmed the direction is stable
- the user explicitly asks to write a design doc, development plan, or both
- the repository expects docs under `docs/` and plans under `plan/`
- you should now transition from clarified requirements into repository documents

Do not use this skill when:
- the user is still exploring requirements and has not confirmed direction
- the session is pure implementation with no documentation request
- the user only wants a brief chat summary rather than repository docs

## Category Placement

- UI / UX / layout / toolbar / inspector / window / interaction: `docs/UI/` and `plan/UI/`
- Backup / sync / iCloud / WebDAV: `docs/backup/` and `plan/backup/`
- Backend / storage / compatibility / migration: `docs/Backend/` or repo-specific backend folders, with matching `plan/` placement when such convention exists
- If no clear subfolder convention exists, fall back to repo root `docs/` and `plan/`

## Drafting Checklist

1. Confirm requirements clarification is complete enough to freeze scope for the current draft.
2. Read adjacent implementation files first.
3. Read one or two nearby docs/plans from the same area to match house style.
4. Check for same-prefix existing docs before creating new ones.
5. If a same-prefix doc exists, compare it and ask append versus overwrite before writing.
6. Write the design doc before the plan.
7. State the current architecture and chosen direction.
8. Separate in-scope work from deferred follow-ups.
9. Add i18n expectations whenever user-facing text or controls are involved.
10. Add compile, manual, and regression checks.
11. Link the design doc from the plan.
12. Keep wording concrete enough that implementation tasks can be derived directly.

## Good Design Doc Signals

- It names the exact host views, models, and files likely to change.
- It explains why the chosen UI/container pattern fits the current codebase.
- It documents what will not be done in the current session.
- It records width, toolbar, state, and empty-state behavior for UI work.
- It includes forward-looking prewiring only when that directly supports the current scope.

## Good Plan Signals

- Phase 1 sets up shell, state, and containers.
- Later phases add placeholders or scoped follow-up wiring.
- Final tasks validate build and update plan state.
- Tasks are small enough to map cleanly to commits.
- Each completed task is expected to end with one git commit so history stays atomic and reviewable.
