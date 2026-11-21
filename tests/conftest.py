"""Shared pytest configuration."""


def pytest_addoption(parser):
    parser.addoption(
        "--update-reference-output",
        action="store_true",
        help="overwrite reference output of the e2e tests",
    )
