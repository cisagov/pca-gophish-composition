"""The gophish-init library."""
from ._version import __version__  # noqa: F401
from .gophish_init import configure, create_send_profile

__all__ = ["configure", "create_send_profile"]
