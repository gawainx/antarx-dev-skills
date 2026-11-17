"""Command-line interface."""

from importlib.metadata import PackageNotFoundError, version
from pathlib import Path
from typing import Annotated

import typer
from loguru import logger
from rich.console import Console

from crkit.logging import configure_logging
from crkit.rules import CursorPathError, install_bundled_rules

console = Console(stderr=True, soft_wrap=True)
app = typer.Typer(
    add_completion=False,
    no_args_is_help=True,
    rich_markup_mode="rich",
    pretty_exceptions_show_locals=False,
)


def distribution_version() -> str:
    try:
        return version("crkit")
    except PackageNotFoundError:
        return "0.1.0"


def _print_version(value: bool) -> None:
    if not value:
        return
    console.print(distribution_version())
    raise typer.Exit()


@app.callback()
def cli(
    _show_version: Annotated[
        bool,
        typer.Option(
            "--version",
            "-V",
            help="Show the installed version and exit.",
            callback=_print_version,
            is_eager=True,
        ),
    ] = False,
) -> None:
    """Initialize a project's .cursor directory from bundled rule templates."""
    configure_logging()


def _relative_path(project_directory: Path, path: Path) -> str:
    return path.relative_to(project_directory).as_posix()


@app.command()
def init() -> None:
    """Create bundled Cursor rules in the current directory."""
    project_directory = Path.cwd()
    try:
        created, skipped = install_bundled_rules(project_directory)
    except CursorPathError as exc:
        logger.error("Path is not a directory: {}", exc.path)
        console.print(f"Not a directory: {exc.path}")
        raise typer.Exit(1) from exc
    except FileNotFoundError as exc:
        logger.error("Bundled rule template is missing: {}", exc)
        console.print(f"Bundled rule template is missing: {exc}")
        raise typer.Exit(1) from exc

    for path in skipped:
        console.print(f"File already exists: {_relative_path(project_directory, path)}")
    if created:
        console.print("Created rules.")
        for path in created:
            console.print(_relative_path(project_directory, path))


def main() -> None:
    configure_logging()
    app()
