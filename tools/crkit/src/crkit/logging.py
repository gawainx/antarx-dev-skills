"""Log configuration for the crkit process."""

import sys

from loguru import logger


def configure_logging() -> None:
    """Send process logs to stderr through loguru."""
    logger.remove()
    logger.add(
        sys.stderr,
        level="INFO",
        backtrace=False,
        diagnose=False,
        colorize=True,
        format="{time:YYYY-MM-DD HH:mm:ss} | {level} | {message}",
    )
