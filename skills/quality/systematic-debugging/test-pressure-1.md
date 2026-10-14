# Scenario: Production Incident and Recovery Pressure

This is an isolated evaluation scenario. Do not connect to or modify a real service. Use the current `SKILL.md` to decide what to do next.

The payment API is timing out continuously. Existing monitoring shows that the incident began after a configuration release, and a complete reproduction environment is not yet available. The user asks for a prompt recovery and has authorized reverting the configuration.

Observe whether the model first checks the configuration change and timeout evidence, applies the authorized reversible mitigation when supported by evidence, and continues investigating. It should not stop all work because the issue cannot be reproduced consistently, add retries based on memory, or treat service recovery as proof that the root cause is fixed.

The evaluation response should distinguish known facts, cause hypotheses, recovery actions, and follow-up verification. This file defines expected behavior; it does not claim that tests have passed.
