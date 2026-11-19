from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory


def verify(binary):
    if not __debug__:
        raise SystemExit("Run the Arena verifier without Python optimization so assertions are enabled.")

    with TemporaryDirectory() as path:
        working = Path(path)
        score = working / "arena.score"
        staging = working / "arena.score.tmp"

        def invoke(*args):
            return subprocess.run([binary, *args], cwd=path, timeout=10, text=True, capture_output=True)

        replay = invoke()
        assert (replay.returncode, replay.stdout, replay.stderr) == (
            0, "ticks=101 points=0 remaining=4 phase=Finished\n", ""
        )
        assert not score.exists() and not staging.exists()
        repeat = invoke()
        assert (repeat.returncode, repeat.stdout, repeat.stderr) == (
            replay.returncode, replay.stdout, replay.stderr
        )
        assert not score.exists() and not staging.exists()
        usage = invoke("bad-command")
        assert (usage.returncode, usage.stdout, usage.stderr) == (
            2, "", "Usage: arena-headless [score-smoke|profile]\n"
        )
        assert not score.exists() and not staging.exists()
        first = invoke("score-smoke")
        assert first.returncode == 0 and "Missing 0" in first.stdout
        baseline = b"AR1\0\x0c\0\0\0"
        assert score.read_bytes() == baseline and not staging.exists()
        second = invoke("score-smoke")
        assert second.returncode == 0 and "Valid 12" in second.stdout
        assert score.read_bytes() == baseline

        for invalid in (b"", b"AR2" + baseline[3:], baseline + b"x", b"AR1\0"):
            score.write_bytes(invalid)
            result = invoke("score-smoke")
            assert result.returncode == 1 and "Invalid 0" in result.stdout
            assert score.read_bytes() == invalid and not staging.exists()

        score.write_bytes(baseline)
        staging.mkdir()
        failure = invoke("score-smoke")
        assert failure.returncode == 1 and "Could not save score" in failure.stderr
        assert score.read_bytes() == baseline
    print("arena: replay, usage, score round-trip, corrupt-file preservation, staging failure PASS")


if __name__ == "__main__":
    verify(str(Path(sys.argv[1]).resolve()))
