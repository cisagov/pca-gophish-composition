"""pytest plugin configuration.

https://docs.pytest.org/en/latest/writing_plugins.html#conftest-py-plugins
"""
# Third-Party Libraries
import pytest
from python_on_whales import docker


@pytest.fixture(scope="session")
def dockerc():
    """Start up the Docker composition."""
    docker.compose.up(detach=True)
    yield docker
    docker.compose.down()


@pytest.fixture(scope="session")
def gophish_container(dockerc):
    """Return the gophish container from the Docker composition."""
    # find the container by name even if it is stopped already
    return dockerc.compose.ps(services=["gophish"], all=True)[0]


@pytest.fixture(scope="session")
def gophish_tools_container(dockerc):
    """Return the gophish-tools container from the Docker composition."""
    # find the container by name even if it is stopped already
    return dockerc.compose.ps(services=["gophish-tools"], all=True)[0]


@pytest.fixture(scope="session")
def postfix_container(dockerc):
    """Return the postfix container from the Docker composition."""
    # find the container by name even if it is stopped already
    return dockerc.compose.ps(services=["postfix"], all=True)[0]


@pytest.fixture(scope="session")
def mailhog_container(dockerc):
    """Return the mailhog container from the Docker composition."""
    # find the container by name even if it is stopped already
    return dockerc.compose.ps(services=["mailhog"], all=True)[0]


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
