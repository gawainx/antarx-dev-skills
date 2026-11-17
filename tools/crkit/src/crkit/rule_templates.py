"""Bundled Cursor rules, stored as frontmatter fields."""

from collections.abc import Mapping
from typing import NotRequired, TypedDict


class RuleFields(TypedDict):
    description: str
    alwaysApply: bool
    globs: NotRequired[str]


RULE_TEMPLATES: dict[str, RuleFields] = {
    "project-env": {
        "description": "Project development environment conventions",
        "alwaysApply": True,
    },
    "project-doc": {
        "description": "Project documentation rules",
        "alwaysApply": True,
    },
}

_FIELD_ORDER = ("description", "globs", "alwaysApply")


def _yaml_string(value: str) -> str:
    reserved = {"true", "false", "null", "yes", "no"}
    special = set(":#{}[]&*!|>%@`'\",\\\n")
    needs_quotes = (
        value == ""
        or value != value.strip()
        or value.lower() in reserved
        or any(character in special for character in value)
    )
    if needs_quotes:
        escaped = value.replace("\\", "\\\\").replace('"', '\\"')
        return f'"{escaped}"'
    return value


def render_mdc(fields: Mapping[str, object]) -> str:
    """Render Cursor rule frontmatter. The body stays empty."""
    unknown = set(fields) - set(_FIELD_ORDER)
    if unknown:
        names = ", ".join(sorted(unknown))
        raise ValueError(f"Unknown rule field: {names}")
    lines = ["---"]
    for key in _FIELD_ORDER:
        if key not in fields:
            continue
        value = fields[key]
        if key == "alwaysApply":
            if not isinstance(value, bool):
                raise ValueError("alwaysApply must be a boolean")
            rendered = "true" if value else "false"
        else:
            if not isinstance(value, str):
                raise ValueError(f"{key} must be a string")
            rendered = _yaml_string(value)
        lines.append(f"{key}: {rendered}")
    lines.append("---")
    return "\n".join(lines) + "\n"
