# Repository Guidelines

## Project Structure & Module Organization
This repository is the single source of truth for managed Codex assets. The only managed content is `skills/` and `AGENTS.md.root`. Add or update reusable skill definitions under `skills/<skill-name>/SKILL.md`; keep supporting files next to the skill only when they are directly needed. Operational scripts live in `scripts/`, currently `sync_to_local.sh` for deployment and `doctor.sh` for consistency checks. Reference material and plans belong in `docs/`, for example `docs/plans/0001-init-structure.md`.

## Build, Test, and Development Commands
Run all edits from the repository root.

```bash
./scripts/sync_to_local.sh --dry-run
```
Preview what will be copied into `~/.codex/skills` and `~/.codex/AGENTS.md.root`.

```bash
./scripts/sync_to_local.sh
```
Apply the managed content to the local Codex installation.

```bash
./scripts/doctor.sh
```
Verify the repo and local managed copies are aligned; this should exit `0` before you claim completion.

## Coding Style & Naming Conventions
Shell scripts use Bash with `set -euo pipefail`; keep new script changes consistent. Prefer ASCII unless a file already uses Chinese text, which this repository does in several core docs. Name skills with lowercase hyphenated directories such as `skills/requesting-code-review/`. Keep `SKILL.md` concise, action-oriented, and specific to the trigger condition it covers.

## Testing Guidelines
There is no separate unit test suite yet; validation is command-based. Treat `./scripts/doctor.sh` as the required verification gate, and use `./scripts/sync_to_local.sh --dry-run` as a safe preflight check before syncing. If you add automation, place tests under `tests/` and name them after the behavior or script they verify.

## Commit & Pull Request Guidelines
Commits must follow Conventional Commits: `feat: ...`, `refactor: ...`, `docs: ...`, `chore: ...`. The subject must be specific and at least 10 characters after the colon; vague messages like `fix` or `update` are not acceptable. Do not use `git commit --amend`. For pull requests, include the intent, affected paths such as `skills/` or `scripts/`, verification output from `./scripts/doctor.sh`, and screenshots only if the change affects rendered documentation.

## Agent-Specific Notes
Do not manually edit managed copies under `~/.codex/skills`. Make changes in this repo, then run dry-run sync, real sync, and doctor in that order. Never add blacklisted skills to managed content: `skill-creator`, `skill-installer`, and `swiftui-macos-llm-chat-module`.
