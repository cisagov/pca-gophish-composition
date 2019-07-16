#!/usr/bin/env python

"""Gophish-init is a configuration utility for Gophish.

Usage:
  gophish-init [--log-level=LEVEL] [--url=URL] API_KEY
  gophish-init (-h | --help)

Options:
  -h --help              Show this message.
  --url=url              URL for Gophish API endpoint [default: https://localhost:3333]
  --log-level=LEVEL      If specified, then the log level will be set to
                         the specified value.  Valid values are "debug", "info",
                         "warning", "error", and "critical". [default: warning]
"""

import logging
import sys

import docopt
from gophish import Gophish
from gophish.models import SMTP

from ._version import __version__

SENDING_PROFILES = [
    {
        "name": "MailHog",
        "host": "mailhog:1025",
        "from_address": "John Doe <johndoe@example.com>",
    },
    {
        "name": "Postfix",
        "host": "postfix:587",
        "from_address": "John Doe <johndoe@example.com>",
    },
]


def create_send_profile(api, name, host, from_address):
    """Create a new sending profile."""
    logging.info(f"Creating new sending profile named: {name}")
    smtp = SMTP(name=name)
    smtp.host = host
    smtp.from_address = from_address
    smtp.interface_type = "SMTP"
    smtp.ignore_cert_errors = True
    smtp = api.smtp.post(smtp)
    logging.debug(f"New sending profile has id: {smtp.id}")
    return smtp


def configure(api_key, url):
    """Configure gophish using the supplied api key."""
    logging.debug(f"Using API key: {api_key}")
    logging.debug(f"Connecting to: {url}")
    api = Gophish(api_key, host=url, verify=False)
    logging.debug(f"Fetching sending profile names.")
    existing_names = {smtp.name for smtp in api.smtp.get()}
    logging.debug(f"Found: {existing_names}")
    for profile in SENDING_PROFILES:
        if profile["name"] in existing_names:
            logging.warn(
                f"Sending profile {profile['name']} already exists.  Skipping."
            )
            # this profile is already configured (skip)
            continue
        create_send_profile(api, **profile)


def main():
    """Set up logging and call the example function."""
    args = docopt.docopt(__doc__, version=__version__)
    # Set up logging
    log_level = args["--log-level"]
    try:
        logging.basicConfig(
            format="%(asctime)-15s %(levelname)s %(message)s", level=log_level.upper()
        )
    except ValueError:
        logging.critical(
            f'"{log_level}" is not a valid logging level.  Possible values '
            "are debug, info, warning, and error."
        )
        return 1

    configure(args["API_KEY"], args["--url"])

    # Stop logging and clean up
    logging.shutdown()
    return 0


if __name__ == "__main__":
    sys.exit(main())
