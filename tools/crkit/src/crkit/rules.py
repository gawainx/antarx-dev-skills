"""Install the bundled Cursor rule templates into a project."""

from pathlib import Path

from crkit.rule_templates import RULE_TEMPLATES, render_mdc


class CursorPathError(Exception):
    """A .cursor path exists and is not a directory."""

    def __init__(self, path: Path) -> None:
        self.path = path
        super().__init__(str(path))


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
    pending: list[tuple[str, Path]] = []
    for name, fields in RULE_TEMPLATES.items():
        destination = rules_directory / f"{name}.mdc"
        if destination.exists():
            skipped.append(destination)
            continue
        pending.append((render_mdc(fields), destination))

    if pending:
        rules_directory.mkdir(parents=True, exist_ok=True)
        for content, destination in pending:
            destination.write_text(content, encoding="utf-8")
            created.append(destination)
    return created, skipped
