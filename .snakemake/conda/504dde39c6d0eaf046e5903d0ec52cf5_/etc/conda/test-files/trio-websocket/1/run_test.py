import sys
from subprocess import call
from pathlib import Path

FAIL_UNDER = "87"
COV = ["coverage"]
RUN = ["run", "--source=trio_websocket", "--branch", "-m"]
PYTEST = ["pytest", "-vv", "--color=yes", "--tb=long"]
REPORT = ["report", "--show-missing", "--skip-covered", f"--fail-under={FAIL_UNDER}"]
PYTEST_INI = "\n".join(["[pytest]", "trio_mode = true"])

SKIPS = [
    # https://github.com/conda-forge/trio-websocket-feedstock/pull/7
    "test_handshake_exception_before_accept",
    "test_reject_handshake",
    "test_reject_handshake_invalid_info_status",
    "test_client_open_timeout",
    "test_client_close_timeout",
    "test_client_connect_networking_error",
    "test_finalization_dropped_exception",
]


SKIP_OR = " or ".join(SKIPS)
K = ["-k", f"not ({SKIP_OR})"]


if __name__ == "__main__":
    Path("pytest.ini").write_text(PYTEST_INI, encoding="utf-8")
    sys.exit(
        # run the tests
        call([*COV, *RUN, *PYTEST, *K])
        # maybe run coverage
        or call([*COV, *REPORT])
    )
