# Installing antarx-dev-skills for Codex

Enable local skills in Codex via native skill discovery.

## Prerequisites

- Git

## Installation

1. Clone this repository:

```bash
git clone <your-repo-url> ~/.codex/antarx-dev-skills
cd ~/.codex/antarx-dev-skills
```

2. Sync skills into the Codex skills directory:

```bash
./scripts/sync_to_local.sh --dry-run
./scripts/sync_to_local.sh
```

3. Restart Codex (quit and relaunch) so skills are discovered.

## Verify

```bash
./scripts/doctor.sh
```

The source repository can keep skills grouped under `skills/<category>/<skill-name>/`.
The sync script installs them flat under `~/.codex/skills/<skill-name>/`.

## Update

```bash
cd ~/.codex/antarx-dev-skills
git pull
./scripts/sync_to_local.sh
./scripts/doctor.sh
```

## Uninstall

Remove managed skill directories listed in `~/.codex/skills/.antarx-managed-skills`, if you want a full uninstall. Optionally remove local clone:

```bash
rm -rf ~/.codex/antarx-dev-skills
```
