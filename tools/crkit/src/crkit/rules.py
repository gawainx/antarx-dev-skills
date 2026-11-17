"""Install the bundled Cursor rule templates into a project."""

from pathlib import Path

from loguru import logger

BUNDLED_RULE_NAMES = ("project-env.mdc", "project-doc.mdc")


class CursorPathError(Exception):
    """A .cursor path exists and is not a directory."""

    def __init__(self, path: Path) -> None:
        self.path = path
        super().__init__(str(path))


def bundled_rules_directory() -> Path:
    return Path(__file__).resolve().parent / "templates" / "rules"


def install_bundled_rules(project_directory: Path) -> tuple[list[Path], list[Path]]:
    """Create missing bundled rules. Existing rule files are left unchanged."""
    cursor_directory = project_directory / ".cursor"
    if cursor_directory.exists() and not cursor_directory.is_dir():
        raise CursorPathError(cursor_directory)
    rules_directory = cursor_directory / "rules"
    if rules_directory.exists() and not rules_directory.is_dir():
        raise CursorPathError(rules_directory)

    created: list[Path] = []
    skipped: list[Path] = []
    pending: list[tuple[Path, Path]] = []
    templates = bundled_rules_directory()
    for name in BUNDLED_RULE_NAMES:
        destination = rules_directory / name
        if destination.exists():
            logger.info("Rule already exists: {}", destination)
            skipped.append(destination)
            continue
        source = templates / name
        if not source.is_file():
            raise FileNotFoundError(source)
        pending.append((source, destination))

    if pending:
        rules_directory.mkdir(parents=True, exist_ok=True)
        for source, destination in pending:
            destination.write_bytes(source.read_bytes())
            logger.info("Created rule: {}", destination)
            created.append(destination)
    return created, skipped
