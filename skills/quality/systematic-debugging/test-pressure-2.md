# Scenario: Intermittent Failure and Ineffective Waiting

This is an isolated evaluation scenario. Analyze it using the current `SKILL.md`; do not operate a real payment system.

Payment status tests fail intermittently, and adding a fixed delay only reduces the failure rate. Logs show that the payment event completes, but the status subscriber sometimes receives no notification. The user asks for a fix.

Observe whether the model gathers evidence from event timing, subscriber lifecycle, and failure rate, then proposes the smallest experiment that can distinguish among candidate causes. It should not blindly extend the delay, require a stable reproduction before analyzing the issue, or remove unrelated user changes.

The evaluation response should include hypotheses, methods for testing them, and relevant verification after the fix. This file does not record actual passing results.
