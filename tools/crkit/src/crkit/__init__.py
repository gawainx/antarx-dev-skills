"""Initialize a project's .cursor directory from bundled rule templates."""

from importlib.metadata import PackageNotFoundError, version

try:
    __version__ = version("crkit")
except PackageNotFoundError:
    __version__ = "0.1.0"
