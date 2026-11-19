#!/usr/bin/env python3
"""Exercise a previously built English resource-catalog executable.

This is an integration harness, NOT an Odin compiler or a substitute for
recording the installed Odin version and successful odin check/build commands.
Usage: python3 code/tools/verify_native_cli.py /absolute/path/to/executable
Unit 34: python3 code/tools/verify_native_cli.py --profile unit34 /absolute/path/to/executable
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory
from typing import Callable, Union


HELP = (
    "Resource catalog\n"
    "Usage: resource-catalog <command> [argument]\n"
    "Commands:\n"
    "  help                Show this help\n"
    "  check <path>        Check whether a path exists\n"
)

UNIT34_COMMANDS = (
    "  list <directory>    List direct entry names\n"
    "  labels <name>...    Validate a batch of resource labels\n"
    "  export <directory> <label>  Write a JSON report to stdout\n"
    "  import <report.json>        Validate and print the accepted report\n"
)

StreamExpectation = Union[str, Callable[[str], bool]]


def reject_duplicate_members(pairs: list[tuple[str, object]]) -> dict[str, object]:
    """Reject repeated JSON member names, including inside nested entry objects."""
    members: dict[str, object] = {}
    for name, value in pairs:
        if name in members:
            raise ValueError(f"duplicate JSON member: {name}")
        members[name] = value
    return members


def matches(expectation: StreamExpectation, actual: str) -> bool:
    return expectation(actual) if callable(expectation) else actual == expectation


def unit34_help(actual: str) -> bool:
    expected = (HELP + UNIT34_COMMANDS).splitlines(keepends=True)
    actual_lines = actual.splitlines(keepends=True)
    return actual_lines[:3] == expected[:3] and sorted(actual_lines[3:]) == sorted(expected[3:])


def unit34_cases(cwd: Path):
    assets = cwd / "assets"
    assets.mkdir()
    (assets / "z.txt").write_text("z\n", encoding="utf-8")
    (assets / "a.txt").write_text("a\n", encoding="utf-8")
    (cwd / "empty").mkdir()
    report = {
        "format": "resource-catalog", "version": 1, "root": "sample",
        "entries": [{"path": "a.txt", "kind": "file"}, {"path": "z.txt", "kind": "file"}],
    }
    valid_report = json.dumps(report, sort_keys=True) + "\n"
    (cwd / "valid.json").write_bytes(valid_report.encode("utf-8"))
    (cwd / "invalid.json").write_bytes(json.dumps({**report, "version": 99}).encode("utf-8"))
    # Keep duplicate members in raw JSON; a Python dict would erase the defect.
    (cwd / "duplicate-root.json").write_text(
        valid_report.replace('"root": "sample"', '"root": "forged", "root": "sample"', 1),
        encoding="utf-8",
    )
    (cwd / "duplicate-entry.json").write_text(
        valid_report.replace('"path": "a.txt"', '"path": "forged", "path": "a.txt"', 1),
        encoding="utf-8",
    )

    def export_matches(actual: str) -> bool:
        try:
            parsed = json.loads(actual, object_pairs_hook=reject_duplicate_members)
        except (json.JSONDecodeError, ValueError):
            return False
        return json.dumps(parsed, sort_keys=True) + "\n" == valid_report

    def missing_list_diagnostic(actual: str) -> bool:
        # The diagnostic includes operating-system text after the path.
        prefix = "Could not list: absent "
        return actual.startswith(prefix) and actual.endswith("\n") and bool(actual[len(prefix):].strip())

    def missing_export_diagnostic(actual: str) -> bool:
        # The requested operand must be named, not just any listing error.
        prefix = "Could not list: absent "
        return actual.startswith(prefix) and actual.endswith("\n") and bool(actual[len(prefix):].strip())

    return [
        ("labels stay in input order", ["labels", "z", "a"], "z\na\n", "", 0),
        ("duplicate labels", ["labels", "z", "z"], "", "Duplicate label: z\n", 2),
        ("empty label", ["labels", "z", ""], "", "Empty label at position: 2\n", 2),
        ("missing labels", ["labels"], "", "Usage: resource-catalog labels <name>...\n", 2),
        ("sorted direct entries", ["list", "assets"], "a.txt\nz.txt\n", "", 0),
        ("empty directory", ["list", "empty"], "", "", 0),
        ("missing directory", ["list", "absent"], "", missing_list_diagnostic, 1),
        ("missing list operand", ["list"], "", "Usage: resource-catalog list <directory>\n", 2),
        ("extra list operand", ["list", "assets", "extra"], "", "Usage: resource-catalog list <directory>\n", 2),
        ("empty list operand", ["list", ""], "", "Usage: resource-catalog list <directory>\n", 2),
        ("export report", ["export", "assets", "sample"], export_matches, "", 0),
        ("export missing directory", ["export", "absent", "sample"], "", missing_export_diagnostic, 1),
        ("missing export label", ["export", "assets"], "", "Usage: resource-catalog export <directory> <label>\n", 2),
        ("empty export label", ["export", "assets", ""], "", "Usage: resource-catalog export <directory> <label>\n", 2),
        ("extra export operand", ["export", "assets", "sample", "extra"], "", "Usage: resource-catalog export <directory> <label>\n", 2),
        ("import valid report", ["import", "valid.json"], valid_report, "", 0),
        ("import unsupported version", ["import", "invalid.json"], "", "Report rejected: Version\n", 1),
        ("import duplicate root member", ["import", "duplicate-root.json"], "", "Report rejected: Duplicate_Key\n", 1),
        ("import duplicate entry member", ["import", "duplicate-entry.json"], "", "Report rejected: Duplicate_Key\n", 1),
        ("missing import operand", ["import"], "", "Usage: resource-catalog import <report.json>\n", 2),
        ("empty import operand", ["import", ""], "", "Usage: resource-catalog import <report.json>\n", 2),
        ("extra import operand", ["import", "valid.json", "extra"], "", "Usage: resource-catalog import <report.json>\n", 2),
    ]


def run_case(binary: Path, cwd: Path, label: str, args: list[str],
             expected_stdout: StreamExpectation, expected_stderr: StreamExpectation,
             expected_code: int) -> bool:
    try:
        result = subprocess.run([str(binary), *args], cwd=cwd, capture_output=True,
                                text=True, encoding="utf-8", errors="replace", timeout=10)
    except (OSError, subprocess.TimeoutExpired) as exc:
        print(f"FAIL {label}: unable to run executable: {exc}")
        return False
    passed = (result.returncode == expected_code and
              matches(expected_stdout, result.stdout) and
              matches(expected_stderr, result.stderr))
    print(f"{'PASS' if passed else 'FAIL'} {label}")
    if not passed:
        stdout_description = expected_stdout.__name__ if callable(expected_stdout) else repr(expected_stdout)
        stderr_description = expected_stderr.__name__ if callable(expected_stderr) else repr(expected_stderr)
        print(f"  expected: exit={expected_code} stdout={stdout_description} stderr={stderr_description}")
        print(f"  observed: exit={result.returncode} stdout={result.stdout!r} stderr={result.stderr!r}")
    return passed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("binary", type=Path, help="Path to an already built executable")
    parser.add_argument("--profile", choices=("foundation", "unit34"), default="foundation",
                        help="CLI contract to check (default: foundation)")
    args = parser.parse_args()
    binary = args.binary.expanduser().resolve()
    if not binary.is_file():
        parser.error(f"executable not found: {binary}")
    with TemporaryDirectory(prefix="odin-cli-qa-") as directory:
        cwd = Path(directory)
        (cwd / "present.txt").write_text("fixture\n", encoding="utf-8")
        (cwd / "file with spaces.txt").write_text("fixture\n", encoding="utf-8")
        (cwd / "folder").mkdir()
        help_output = unit34_help if args.profile == "unit34" else HELP
        cases = [
            ("no arguments", [], help_output, "", 0),
            ("help", ["help"], help_output, "", 0),
            ("--help", ["--help"], help_output, "", 0),
            ("help extra", ["help", "extra"], "", "Error: help does not accept extra arguments.\n", 2),
            ("--help extra", ["--help", "extra"], "", "Error: help does not accept extra arguments.\n", 2),
            ("existing file", ["check", "present.txt"], "Found: present.txt\n", "", 0),
            ("existing directory", ["check", "folder"], "Found: folder\n", "", 0),
            ("current directory", ["check", "."], "Found: .\n", "", 0),
            ("file with spaces", ["check", "file with spaces.txt"], "Found: file with spaces.txt\n", "", 0),
            ("missing path", ["check", "missing.txt"], "", "Not found or unavailable: missing.txt\n", 1),
            ("missing path with spaces", ["check", "not here.txt"], "", "Not found or unavailable: not here.txt\n", 1),
            ("missing check operand", ["check"], "", "Usage: resource-catalog check <path>\n", 2),
            ("extra check operand", ["check", "present.txt", "extra"], "", "Usage: resource-catalog check <path>\n", 2),
            ("empty path", ["check", ""], "", "Error: provide a non-empty path.\n", 2),
            ("unknown command", ["unknown"], help_output, "Unknown command: unknown\n", 2),
        ]
        if args.profile == "unit34":
            cases.extend(unit34_cases(cwd))
        passed = sum(run_case(binary, cwd, *case) for case in cases)
        print(f"Native CLI: {passed}/{len(cases)} passed; executable={binary}")
        print("NOTE: this harness does not verify Odin compiler version, build, or check.")
        return 0 if passed == len(cases) else 1


if __name__ == "__main__":
    sys.exit(main())
