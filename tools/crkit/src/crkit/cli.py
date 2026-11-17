"""Command-line interface."""

from importlib.metadata import PackageNotFoundError, version
from typing import Annotated

import typer
from rich.console import Console

from crkit.logging import configure_logging

console = Console(stderr=True)
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


def main() -> None:
    configure_logging()
    app()
