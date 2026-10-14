---
name: systematic-debugging
description: Use when the user asks to investigate a bug, test failure, build error, or unexpected behavior. Find the cause from evidence and verify the fix, scaling the investigation to the problem's complexity.
---

# Systematic Debugging

## 1. Establish the Facts

Read the error, relevant code, and existing logs. Distinguish expected behavior from actual behavior, identify the affected path, and review relevant recent changes. If the issue is reproducible, record the smallest trigger. For intermittent or environment-dependent failures, use logs, event timing, failure rates, and environmental differences as evidence; do not require a stable reproduction before continuing the investigation.

## 2. Test the Cause

Form falsifiable hypotheses about the cause and choose the smallest check or experiment that can distinguish among them. Change only the necessary variable in each experiment, update the hypothesis based on the result, and do not stack unverified patches.

Add diagnostic logging only when the current evidence is insufficient. Compare with a reference implementation only when a relevant one exists, focusing on differences that could affect the failure. When the error and code already identify a simple issue, verify that cause directly without unrelated investigation.

## 3. Fix and Verify

Fix the cause supported by evidence and preserve other existing changes. For behavior that can be asserted automatically, prefer a minimal regression test and confirm it fails before the fix and passes afterward. When automatic reproduction is not possible, verify with relevant logs, integration checks, or repeatable operations, and state what those checks cover.

Run checks for the affected area. Expand verification when new changes, failures, or unresolved risks warrant it; do not rerun checks that already passed when the code has not changed.

When a production incident requires service recovery first, take an evidence-supported, reversible mitigation within the authorized scope. Report the recovery and any unresolved root cause separately; do not present a temporary mitigation as a permanent fix.

## 4. Report the Results

Describe the cause, supporting evidence, changes made, and actual verification results. If the cause remains uncertain, list what has been ruled out and the next check that could narrow the search. Do not declare a fix based only on things looking normal.
