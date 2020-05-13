"""pytest plugin configuration.

https://docs.pytest.org/en/latest/writing_plugins.html#conftest-py-plugins
"""
# Third-Party Libraries
import pytest

<<<<<<< HEAD

@pytest.fixture(scope="session")
def gophish_container(dockerc):
    """Return the gophish container from the docker composition."""
    # find the container by name even if it is stopped already
    return dockerc.containers(service_names=["gophish"], stopped=True)[0]


@pytest.fixture(scope="session")
def postfix_container(dockerc):
    """Return the postfix container from the docker composition."""
    # find the container by name even if it is stopped already
    return dockerc.containers(service_names=["postfix"], stopped=True)[0]


@pytest.fixture(scope="session")
def mailhog_container(dockerc):
    """Return the mailhog container from the docker composition."""
    # find the container by name even if it is stopped already
    return dockerc.containers(service_names=["mailhog"], stopped=True)[0]
=======
MAIN_SERVICE_NAME = "example"
VERSION_SERVICE_NAME = f"{MAIN_SERVICE_NAME}-version"


@pytest.fixture(scope="session")
def main_container(dockerc):
    """Return the main container from the docker composition."""
    # find the container by name even if it is stopped already
    return dockerc.containers(service_names=[MAIN_SERVICE_NAME], stopped=True)[0]


@pytest.fixture(scope="session")
def version_container(dockerc):
    """Return the version container from the docker composition.

    The version container should just output the version of its underlying contents.
    """
    # find the container by name even if it is stopped already
    return dockerc.containers(service_names=[VERSION_SERVICE_NAME], stopped=True)[0]
>>>>>>> 4de6b59dd041229073cb15571ec5a1c005f6cad6


def pytest_addoption(parser):
    """Add new commandline options to pytest."""
    parser.addoption(
        "--runslow", action="store_true", default=False, help="run slow tests"
    )


def pytest_collection_modifyitems(config, items):
    """Modify collected tests based on custom marks and commandline options."""
    if config.getoption("--runslow"):
        # --runslow given in cli: do not skip slow tests
        return
    skip_slow = pytest.mark.skip(reason="need --runslow option to run")
    for item in items:
        if "slow" in item.keywords:
            item.add_marker(skip_slow)
