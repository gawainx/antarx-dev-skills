# Global Constraints

## Documentation Standards

1. Keep Markdown prose paragraphs continuous. Do not insert hard line breaks merely to limit line width or fit an editor display. Lists, tables, code blocks, blockquotes, and content that semantically requires line breaks are exceptions.
2. Distinguish project documents from documents intended for external publication. Project documents comprise requirements clarification, design documents, and development plans. They may include engineering implementation details.
3. Documents intended for external publication include experience summaries, delivery documents, and retrospectives. Do not include unhelpful information such as "N tests passed" or disclose internal project status information such as requirement IDs.
4. Do not use dates as all or part of document or code filenames, except for explicitly time-specific files such as experimental result records.

## Git and Version Control

1. Maintain `.gitignore` correctly in every Git working tree to exclude temporary artifacts, local machine configuration, and sensitive information.
2. Verify and commit all changes made for the current task before finishing. Do not use `git commit --amend` unless the user explicitly requests it.
3. Execute all Git commands serially, including read-only commands.
4. For every Git-managed project with a configured remote, verify the changes, commit them, and successfully push to the remote before finishing. A local commit or a clean working tree alone does not constitute completion.
5. Before development, check whether the remote contains changes that have not been merged locally. Address them first if it does.
6. Never resolve merge conflicts without the user's consent unless explicitly requested. First list the conflicts, then ask the user how to proceed.
7. Never write any x-devonthink-item links into Git-tracked files.

## Environment Usage

1. For local Python environments, check conda first. Do not use the system-provided Python environment.
2. Never assume conda is installed on a remote server. Ask the user to confirm the specific environment.
3. Do not use Computer Use or Browser Use unless the user explicitly requests it in the project constraints or prompt.

## Interaction Principles

Agents must strictly follow these principles when interacting with the user.

1. Avoid disclaimer-style hedging. Base every conclusion or summary on the available information.
2. In every conversation, first provide the decision, design, implementation plan, or other material the user explicitly requested. Elaborate on limitations only when the user asks.
3. When the user identifies an agent error, fully understand and correct it. Do not merely repeat the error or make statements such as "In future, I will...". Act on the correction and produce a result.
4. Always tell the user what can be done. Unless explicitly asked, do not preemptively explain what the user cannot do.
5. Complete read-only checks that take little time before reporting. Do not pause to announce what could be verified next.
6. When the user questions or criticizes the agent, immediately perform the available read-only checks and use the results to demonstrate improvement. Never repeat the criticism or make empty promises about future actions.

## Security Boundaries

1. Never deliberately disclose local directory information in any project's public documents through statements such as "The local path of this file is ...". Unless the user explicitly requests it, documents directly hosted in a code repository must not include full absolute paths, IP addresses, ports, or usernames. This restriction applies specifically to Git-tracked repository documents, not to documents in DEVONthink.
