---
name: requirement-clarification
description: Clarify goals, scope, and acceptance criteria when the user explicitly asks to clarify, reorganize, or continue confirming requirements. Ordinary design, planning, or implementation requests do not trigger this skill automatically.
---

# Requirement Clarification

## 1. Understand the user's requirement

Read the user's current description and relevant conversation first. Identify who encounters what problem in which scenario, the desired outcome, explicit constraints, and how completion will be judged. Briefly restate your understanding. Mark missing information for verification; do not invent answers.

Identify ambiguous core concepts that could change scope, inspect the repository with those gaps in mind, then confirm them with the user. Do not directly replace the user's concepts with technical patterns or let existing modules define the requirement's scope.

When the user corrects your understanding, update the requirement, withdraw conclusions based on the old interpretation, and continue.

## 2. Research project context and external sources

Requirement research must cover the target project's code and documents, its corresponding DEVONthink group, and the internet. The target project is the code repository for the requirement that triggered this skill. Derive all project sources from that repository and user-provided context; do not source them from, or fall back to, the skill's source repository or installation directory.

Use `rg` and `rg --files` to find relevant source code and documents, skipping dependency, cache, and build directories. Verify current behavior, existing capabilities, and actual limitations.

Read `AGENTS.md` and `AGENTS.*.md` in the target repository, extract their designated DEVONthink groups, and combine them with sources explicitly provided by the user. Follow explicit user restrictions or replacements of the search scope. Discover whether DEVONthink MCP is available through the current environment's tool discovery mechanism. Search and read relevant requirements, designs, decisions, and other material within those groups and their subgroups; do not expand to the whole database by default. If no group is configured and the user supplied no source, ask for one. If a link is inaccessible or tools are unavailable, explain the specific blocker and continue other feasible research; do not mark blocked searches as completed.

Cross-check DEVONthink material against the repository's current state, retaining source references for relevant records. Use historical documents to verify facts without automatically inheriting old exclusions such as "out of scope" or "not implemented yet." If an old restriction may still affect the current goal, investigate why and bring conflicts requiring a user decision to the next step. Skill source should describe source-discovery rules only; do not embed actual groups, absolute paths, or other local details from the maintenance environment.

Proactively search the internet, especially open-source projects that address similar requirements and their documentation, code, and examples. Understand their capabilities, usage, and limitations without waiting for an unfamiliar term. Compare relevant findings with the user's scenario and repository state, explain what can be reused and under which conditions it does not apply, and cite sources. Do not treat an external implementation as the user's requirement.

Verify uncertain external terms, product capabilities, or standards using reliable sources first; confirm user-defined concepts in the next step. When resuming or revisiting clarification, reuse research that remains valid and investigate only changes and gaps.

## 3. Resolve questions that affect the requirement

Check whether unresolved information changes the goal, scope, user-visible behavior, or acceptance criteria. Verify what can be resolved through existing context or research yourself. Ask questions requiring user judgment in the conversation, at most five per round, prioritizing issues that affect later questions.

Every question must explain the relevant repository state or verified capability gap, its effect on the current requirement, and the decision the user must make. Provide the corresponding file or code location. If no related implementation was found, describe the search scope and gap without inventing a connection. Do not ask a question unless you can explain which requirement conclusion its answer affects.

For choices between approaches, provide a recommendation, genuinely viable alternatives, and the main differences. For missing facts, ask directly for the information instead of forcing a multiple-choice format.

Wait for the user's answer, update the requirement, then check remaining questions. If no user decision is needed, proceed directly to the next step.

For layout, workflows, states, or relationships, include a concise Mermaid diagram or text sketch when it is clearer than prose, marking boundaries that need discussion.

## 4. Present the clarification

Use this order, combining items when the content is brief:

- Requirement understanding: user scenario, goal, and expected outcome.
- Scope and constraints: explicitly included items and items explicitly excluded by the user.
- Acceptance criteria: observable, verifiable completion conditions.
- Project connections: relevant repository state, DEVONthink material, limitations, and supporting evidence, with sources. Include findings and sources from open-source implementations when useful.

If user decisions remain unresolved, continue clarification in the conversation instead of writing them into the requirement clarification document. Record only established requirements, facts, and decisions in the document.

## 5. Save confirmed requirements

Save only when the user requests it or the project workflow requires persistence. For discussion or review alone, respond in the conversation; completing clarification does not automatically authorize writing a document.

### Choose a save location

- Use the current environment's tool discovery mechanism to check whether DEVONthink MCP is available.
- When available, read and invoke `$dt-writing-project-documents` to save this skill's output, following that skill's procedure.
- Save to `docs/` at the current project root only when MCP is not installed or enabled.

### Single requirement document

- Default to `r001-short-title.md`, with requirement clarification, design, and development plan as level-two sections in the same document. Write only confirmed clarification now; update the same document for later design and planning without inventing content in advance or creating separate files.
- Before creation, check the current project's existing requirement documents and IDs. Reuse the document and ID for an existing requirement. For a new one, increment the largest ID, starting at `r001` if none exist. Use at least three digits and no date in the filename.
- Reuse the established requirement document for later design and planning.
- Before consolidating existing separate documents, confirm the target and scope and preserve original files and unrelated content. Do not move, delete, or renumber documents merely to adopt a new default.

### Local storage

Use `<project-root>/docs/r001-short-title.md`, creating the directory if needed. After saving, verify the new content and preserved sections, and provide the file path to the user.

End the workflow after completing this round's output and authorized saving. Continue to design, development planning, or implementation only when the user explicitly requests it.
