#!/usr/bin/env pytest -vs
"""Tests for Docker composition."""

# Standard Python Libraries
import time

READY_MESSAGES = {
    "gophish": "Starting admin server at",
    "postfix": "daemon started",
    "mailhog": "Creating API v2 with WebPath",
}


def test_container_count(dockerc):
    """Verify the test composition and container."""
    # stopped parameter allows non-running containers in results
    assert (
        len(dockerc.compose.ps(all=True)) == 4
    ), "Wrong number of containers were started."


def test_successful_exit_gophish_tools(gophish_tools_container):
    """Confirm successful exit code from gophish-tools container."""
    SUCCESSFUL_EXIT = 0
    TIMEOUT = 10
    for i in range(TIMEOUT):
        if gophish_tools_container.state.exit_code == SUCCESSFUL_EXIT:
            break
        time.sleep(1)
    else:
        raise Exception(
            f"Container did not exit successfully.  "
            f'Expected exit code "{SUCCESSFUL_EXIT}" within {TIMEOUT} seconds.'
        )


def test_wait_for_ready_gophish(gophish_container):
    """Wait for gophish container to be ready."""
    TIMEOUT = 10
    ready_message = READY_MESSAGES["gophish"]
    for i in range(TIMEOUT):
        if ready_message in gophish_container.logs():
            break
        time.sleep(1)
    else:
        raise Exception(
            f"Container does not seem ready.  "
            f'Expected "{ready_message}" in the log within {TIMEOUT} seconds.'
        )


def test_wait_for_ready_postfix(postfix_container):
    """Wait for postfix container to be ready."""
    TIMEOUT = 10
    ready_message = READY_MESSAGES["postfix"]
    for i in range(TIMEOUT):
        if ready_message in postfix_container.logs():
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
        if ready_message in mailhog_container.logs():
            break
        time.sleep(1)
    else:
        raise Exception(
            f"Container does not seem ready.  "
            f'Expected "{ready_message}" in the log within {TIMEOUT} seconds.'
        )
