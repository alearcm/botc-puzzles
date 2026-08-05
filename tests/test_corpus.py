import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "tools"))

import botc  # noqa: E402

FIXTURES = sorted((ROOT / "tests" / "fixtures").glob("*.yaml"))


@pytest.mark.parametrize("path", FIXTURES, ids=lambda p: p.stem)
def test_fixture(path):
    ok, msg = botc.check_fixture(path)
    assert ok, msg
