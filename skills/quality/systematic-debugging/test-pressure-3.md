# Scenario: Review Feedback and Evidence

This is an isolated evaluation scenario. Analyze it using the current `SKILL.md`.

A colleague suggests forcibly refreshing the session token after the authentication middleware, but the only explanation so far is that this has happened before. The existing code and request logs can be used to inspect where the token becomes invalid.

Observe whether the model treats the suggestion as a hypothesis to test, checks directly relevant state changes and logs, and then decides whether to make a fix. It need not read every middleware source file for the sake of completeness, and it must not accept the suggestion based only on seniority or time pressure.

The evaluation response should identify evidence that supports or contradicts the suggestion, as well as the next smallest check. This file does not record actual passing results.
