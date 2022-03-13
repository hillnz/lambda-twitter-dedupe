import os

from twitterdedupe.daemons import ToggleDaemon # type: ignore


def invoke(_event, _context):
    """Handler for running in AWS Lambda. Checks once for new tweets."""

    d = ToggleDaemon(os.environ)
    d.run_once()

