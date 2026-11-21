"""End-to-end tests: run the full analyze + reason pipeline on each test case
and compare the results against the stored reference output.
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

# Test cases are identified by folders with a Makefile in it
# TODO: maybe not the most elegat thing to do but good enough right now
E2E_DIR = Path(__file__).parent
CASES_DIR = E2E_DIR / "cases"
CASES = sorted(p.parent.name for p in CASES_DIR.glob("*/Makefile"))
REQUIRED_TOOLS = ["cc", "make", "objdump", "sqlite3", "git"]

pytestmark = pytest.mark.e2e


@pytest.fixture(scope="session")
def tools_available():
    missing = [t for t in REQUIRED_TOOLS if shutil.which(t) is None]
    if missing:
        pytest.skip(f"e2e tools not installed: {', '.join(missing)}")


@pytest.fixture(scope="session")
def script_env():
    # test-single.sh invokes `python3 -m inspectre_gadget`: make sure that
    # resolves to the interpreter running pytest (e.g. the venv's).
    venv_bin = str(Path(sys.executable).parent)
    path = os.pathsep.join([venv_bin, os.environ.get("PATH", "")])
    return {**os.environ, "PATH": path}


@pytest.mark.parametrize("case", CASES)
def test_e2e(case, request, tools_available, script_env):
    # Nice section that lists how to reproduce specific failing cases
    request.node.user_properties.append(
        ("rerun", f"tests/end2end/test-single.sh {case}")
    )

    build = subprocess.run(
        ["make", "-s", "-C", str(CASES_DIR / case)],
        capture_output=True,
        text=True,
    )
    assert build.returncode == 0, f"build failed:\n{build.stdout}{build.stderr}"

    cmd = [str(E2E_DIR / "test-single.sh"), case]
    if request.config.getoption("--update-reference-output"):
        cmd.append("--update")

    res = subprocess.run(
        cmd,
        env=script_env,
        capture_output=True,
        text=True,
    )

    assert res.returncode == 0, (
        f"{case}: differs from reference output, "
        f"re-run with `tests/end2end/test-single.sh {case}`\n"
        f"{res.stdout}{res.stderr}"
    )
