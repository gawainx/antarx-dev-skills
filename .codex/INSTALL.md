# Installing antarx-dev-skills for Codex

Enable local skills in Codex via native skill discovery.

## Prerequisites

- Git

## Installation

1. Clone this repository:

```bash
git clone <your-repo-url> ~/.codex/antarx-dev-skills
```

2. Create skills symlink:

```bash
mkdir -p ~/.agents/skills
ln -s ~/.codex/antarx-dev-skills/skills ~/.agents/skills/antarx-dev-skills
```

3. Restart Codex (quit and relaunch) so skills are discovered.

## Verify

```bash
ls -la ~/.agents/skills/antarx-dev-skills
```

You should see a symlink pointing to `~/.codex/antarx-dev-skills/skills`.

## Update

```bash
cd ~/.codex/antarx-dev-skills && git pull
```

## Uninstall

```bash
rm ~/.agents/skills/antarx-dev-skills
```

Optionally remove local clone:

```bash
rm -rf ~/.codex/antarx-dev-skills
```
