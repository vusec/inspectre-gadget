"""Shared pytest configuration."""


def pytest_addoption(parser):
    parser.addoption(
        "--update-reference-output",
        action="store_true",
        help="overwrite reference output of the e2e tests",
    )


def pytest_terminal_summary(terminalreporter):
    """List the reproducer command of every failed test that recorded one."""
    reruns = [
        dict(rep.user_properties)["rerun"]
        for rep in terminalreporter.stats.get("failed", [])
        if "rerun" in dict(rep.user_properties)
    ]
    if reruns:
        terminalreporter.section("e2e failures reproducers")
        terminalreporter.line("Commands to reproduce failing e2e tests (one per line):\n")
        for cmd in reruns:
            terminalreporter.line(cmd)
