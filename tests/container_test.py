#!/usr/bin/env pytest -vs
<<<<<<< HEAD
"""Tests for Docker composition."""

# Standard Python Libraries
import time

READY_MESSAGES = {
    "gophish": "Starting admin server at",
    "postfix": "daemon started",
    "mailhog": "Creating API v2 with WebPath",
}
=======
"""Tests for example container."""

# Standard Python Libraries
import os
import time

# Third-Party Libraries
import pytest

ENV_VAR = "ECHO_MESSAGE"
ENV_VAR_VAL = "Hello World from docker-compose!"
READY_MESSAGE = "This is a debug message"
SECRET_QUOTE = (
    "There are no secrets better kept than the secrets everybody guesses."  # nosec
)
RELEASE_TAG = os.getenv("RELEASE_TAG")
VERSION_FILE = "src/version.txt"
>>>>>>> 4de6b59dd041229073cb15571ec5a1c005f6cad6


def test_container_count(dockerc):
    """Verify the test composition and container."""
    # stopped parameter allows non-running containers in results
    assert (
<<<<<<< HEAD
        len(dockerc.containers(stopped=True)) == 3
    ), "Wrong number of containers were started."


def test_wait_for_ready_gophish(gophish_container):
    """Wait for gophish container to be ready."""
    TIMEOUT = 10
    ready_message = READY_MESSAGES["gophish"]
    for i in range(TIMEOUT):
        if ready_message in gophish_container.logs().decode("utf-8"):
=======
        len(dockerc.containers(stopped=True)) == 2
    ), "Wrong number of containers were started."


def test_wait_for_ready(main_container):
    """Wait for container to be ready."""
    TIMEOUT = 10
    for i in range(TIMEOUT):
        if READY_MESSAGE in main_container.logs().decode("utf-8"):
>>>>>>> 4de6b59dd041229073cb15571ec5a1c005f6cad6
            break
        time.sleep(1)
    else:
        raise Exception(
            f"Container does not seem ready.  "
<<<<<<< HEAD
            f'Expected "{ready_message}" in the log within {TIMEOUT} seconds.'
        )


def test_wait_for_ready_postfix(postfix_container):
    """Wait for postfix container to be ready."""
    TIMEOUT = 10
    ready_message = READY_MESSAGES["postfix"]
    for i in range(TIMEOUT):
        if ready_message in postfix_container.logs().decode("utf-8"):
            break
        time.sleep(1)
    else:
        raise Exception(
            f"Container does not seem ready.  "
            f'Expected "{ready_message}" in the log within {TIMEOUT} seconds.'
        )


def test_wait_for_ready_mailhog(mailhog_container):
    """Wait for mailhog container to be ready."""
    TIMEOUT = 10
    ready_message = READY_MESSAGES["mailhog"]
    for i in range(TIMEOUT):
        if ready_message in mailhog_container.logs().decode("utf-8"):
            break
        time.sleep(1)
    else:
        raise Exception(
            f"Container does not seem ready.  "
            f'Expected "{ready_message}" in the log within {TIMEOUT} seconds.'
        )
=======
            f'Expected "{READY_MESSAGE}" in the log within {TIMEOUT} seconds.'
        )


def test_wait_for_exits(main_container, version_container):
    """Wait for containers to exit."""
    assert main_container.wait() == 0, "Container service (main) did not exit cleanly"
    assert (
        version_container.wait() == 0
    ), "Container service (version) did not exit cleanly"


def test_output(main_container):
    """Verify the container had the correct output."""
    main_container.wait()  # make sure container exited if running test isolated
    log_output = main_container.logs().decode("utf-8")
    assert SECRET_QUOTE in log_output, "Secret not found in log output."


@pytest.mark.skipif(
    RELEASE_TAG in [None, ""], reason="this is not a release (RELEASE_TAG not set)"
)
def test_release_version():
    """Verify that release tag version agrees with the module version."""
    pkg_vars = {}
    with open(VERSION_FILE) as f:
        exec(f.read(), pkg_vars)  # nosec
    project_version = pkg_vars["__version__"]
    assert (
        RELEASE_TAG == f"v{project_version}"
    ), "RELEASE_TAG does not match the project version"


def test_log_version(version_container):
    """Verify the container outputs the correct version to the logs."""
    version_container.wait()  # make sure container exited if running test isolated
    log_output = version_container.logs().decode("utf-8").strip()
    pkg_vars = {}
    with open(VERSION_FILE) as f:
        exec(f.read(), pkg_vars)  # nosec
    project_version = pkg_vars["__version__"]
    assert (
        log_output == project_version
    ), f"Container version output to log does not match project version file {VERSION_FILE}"


def test_container_version_label_matches(version_container):
    """Verify the container version label is the correct version."""
    pkg_vars = {}
    with open(VERSION_FILE) as f:
        exec(f.read(), pkg_vars)  # nosec
    project_version = pkg_vars["__version__"]
    assert (
        version_container.labels["version"] == project_version
    ), "Dockerfile version label does not match project version"
>>>>>>> 4de6b59dd041229073cb15571ec5a1c005f6cad6
