"""Unit tests for the native CLI harness itself (not Odin runtime evidence)."""
from __future__ import annotations

import importlib.util
from pathlib import Path
from tempfile import TemporaryDirectory
import subprocess
import unittest
from unittest.mock import patch

MODULE_PATH = Path(__file__).with_name("verify_native_cli.py")
spec = importlib.util.spec_from_file_location("verify_native_cli", MODULE_PATH)
assert spec is not None and spec.loader is not None
harness = importlib.util.module_from_spec(spec)
spec.loader.exec_module(harness)


class NativeHarnessContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.binary = Path("/synthetic/resource-catalog")
        self.cwd = Path("/synthetic/work")

    def test_exact_streams_and_status_pass(self) -> None:
        observed = subprocess.CompletedProcess([], 2, "Resource catalog\n", "Unknown command: bad\n")
        with patch.object(harness.subprocess, "run", return_value=observed) as run:
            self.assertTrue(harness.run_case(self.binary, self.cwd, "mixed streams",
                                             ["bad"], "Resource catalog\n",
                                             "Unknown command: bad\n", 2))
            self.assertEqual(run.call_args.args[0], [str(self.binary), "bad"])
            self.assertEqual(run.call_args.kwargs["cwd"], self.cwd)
            self.assertTrue(run.call_args.kwargs["capture_output"])

    def test_wrong_stream_fails_even_with_correct_status(self) -> None:
        observed = subprocess.CompletedProcess([], 2, "Error\n", "")
        with patch.object(harness.subprocess, "run", return_value=observed):
            self.assertFalse(harness.run_case(self.binary, self.cwd, "wrong stream",
                                              [], "", "Error\n", 2))

    def test_wrong_exit_code_fails_even_with_matching_output(self) -> None:
        observed = subprocess.CompletedProcess([], 0, "Found: x\n", "")
        with patch.object(harness.subprocess, "run", return_value=observed):
            self.assertFalse(harness.run_case(self.binary, self.cwd, "wrong status",
                                              ["check", "x"], "Found: x\n", "", 1))

    def test_unit34_export_rejects_duplicate_json_members(self) -> None:
        # json.loads() normally keeps the last duplicate key. That would make
        # both malformed exports compare equal to the expected report.
        with TemporaryDirectory() as directory:
            cases = harness.unit34_cases(Path(directory))
            export_case = next(case for case in cases if case[0] == "export report")
            accepts_export = export_case[2]
            good = (Path(directory) / "valid.json").read_text(encoding="utf-8")
            duplicate_root = good.replace(
                '"root": "sample"', '"root": "forged", "root": "sample"', 1)
            duplicate_entry = good.replace(
                '"path": "a.txt"', '"path": "forged", "path": "a.txt"', 1)
            self.assertTrue(accepts_export(good))
            self.assertFalse(accepts_export(duplicate_root))
            self.assertFalse(accepts_export(duplicate_entry))

    def test_unit34_export_contract_checks_process_streams(self) -> None:
        with TemporaryDirectory() as directory:
            cases = harness.unit34_cases(Path(directory))
            _, args, expected_stdout, expected_stderr, expected_code = next(
                case for case in cases if case[0] == "export report")
            good = (Path(directory) / "valid.json").read_text(encoding="utf-8")
            duplicate = good.replace(
                '"root": "sample"', '"root": "wrong", "root": "sample"', 1)
            scenarios = [
                (good, "", 0, True),
                (duplicate, "", 0, False),
                (good, "warning\n", 0, False),
                (good, "", 1, False),
            ]
            for stdout, stderr, status, accepted in scenarios:
                with self.subTest(stdout=stdout, stderr=stderr, status=status):
                    observed = subprocess.CompletedProcess([], status, stdout, stderr)
                    with patch.object(harness.subprocess, "run", return_value=observed):
                        self.assertEqual(
                            harness.run_case(self.binary, Path(directory), "export report",
                                             args, expected_stdout, expected_stderr, expected_code),
                            accepted,
                        )

    def test_unit34_duplicate_import_fixtures_and_stream_contract(self) -> None:
        # Verify the raw fixtures preserve the defect; json.loads without a
        # pairs hook would silently discard the first occurrence.
        with TemporaryDirectory() as directory:
            cwd = Path(directory)
            cases = harness.unit34_cases(cwd)
            for label, filename, member, count in (
                ("import duplicate root member", "duplicate-root.json", "root", 2),
                ("import duplicate entry member", "duplicate-entry.json", "path", 3),
            ):
                with self.subTest(label=label):
                    source = (cwd / filename).read_text(encoding="utf-8")
                    self.assertEqual(source.count(f'"{member}":'), count)
                    with self.assertRaisesRegex(ValueError, "duplicate JSON member"):
                        harness.json.loads(
                            source, object_pairs_hook=harness.reject_duplicate_members)
                    _, args, expected_stdout, expected_stderr, expected_code = next(
                        case for case in cases if case[0] == label)
                    self.assertEqual(args, ["import", filename])
                    self.assertEqual((expected_stdout, expected_stderr, expected_code),
                                     ("", "Report rejected: Duplicate_Key\n", 1))
                    for observed, accepted in (
                        (subprocess.CompletedProcess([], 1, "",
                                                     "Report rejected: Duplicate_Key\n"), True),
                        (subprocess.CompletedProcess([], 1, "partial",
                                                     "Report rejected: Duplicate_Key\n"), False),
                        (subprocess.CompletedProcess([], 0, "",
                                                     "Report rejected: Duplicate_Key\n"), False),
                        (subprocess.CompletedProcess([], 1, "",
                                                     "Report rejected: Version\n"), False),
                        (subprocess.CompletedProcess([], 1, "",
                                                     "Report rejected: Duplicate_Key\nextra\n"), False),
                    ):
                        with patch.object(harness.subprocess, "run", return_value=observed):
                            self.assertEqual(
                                harness.run_case(self.binary, cwd, label, args,
                                                 expected_stdout, expected_stderr,
                                                 expected_code),
                                accepted,
                            )

    def test_unit34_missing_export_diagnostic_names_requested_path(self) -> None:
        with TemporaryDirectory() as directory:
            cases = harness.unit34_cases(Path(directory))
            _, args, expected_stdout, expected_stderr, expected_code = next(
                case for case in cases if case[0] == "export missing directory")
            self.assertEqual(args, ["export", "absent", "sample"])
            for diagnostic, accepted in (
                ("Could not list: absent file not found\n", True),
                ("Could not list: other file not found\n", False),
                ("Could not list: permission denied\n", False),
                ("Could not list: absent \n", False),
            ):
                with self.subTest(diagnostic=diagnostic):
                    observed = subprocess.CompletedProcess([], 1, "", diagnostic)
                    with patch.object(harness.subprocess, "run", return_value=observed):
                        self.assertEqual(
                            harness.run_case(self.binary, Path(directory),
                                             "export missing directory", args,
                                             expected_stdout, expected_stderr, expected_code),
                            accepted,
                        )

    def test_unit34_arity_and_empty_operands_reject_without_payload(self) -> None:
        # The checkpoint dispatch checks argument count before touching files.
        # Rejecting extra operands is important: otherwise a misspelled command
        # can appear successful while silently ignoring reader-supplied input.
        with TemporaryDirectory() as directory:
            cwd = Path(directory)
            cases = harness.unit34_cases(cwd)
            labels = (
                "extra list operand", "empty list operand",
                "empty export label", "extra export operand",
                "empty import operand", "extra import operand",
            )
            for label in labels:
                with self.subTest(label=label):
                    _, args, stdout, stderr, status = next(
                        case for case in cases if case[0] == label)
                    self.assertEqual((stdout, status), ("", 2))
                    self.assertTrue(stderr.startswith("Usage: resource-catalog "))
                    observed = subprocess.CompletedProcess([], 2, "", stderr)
                    with patch.object(harness.subprocess, "run", return_value=observed):
                        self.assertTrue(harness.run_case(
                            self.binary, cwd, label, args, stdout, stderr, status))
                    for wrong in (
                        subprocess.CompletedProcess([], 0, "", stderr),
                        subprocess.CompletedProcess([], 2, "partial", stderr),
                        subprocess.CompletedProcess([], 2, "", stderr + "extra\\n"),
                    ):
                        with patch.object(harness.subprocess, "run", return_value=wrong):
                            self.assertFalse(harness.run_case(
                                self.binary, cwd, label, args, stdout, stderr, status))

    def test_timeout_is_failure_not_success(self) -> None:
        with patch.object(harness.subprocess, "run",
                          side_effect=subprocess.TimeoutExpired("resource-catalog", 10)):
            self.assertFalse(harness.run_case(self.binary, self.cwd, "timeout",
                                              [], "", "", 0))

    def test_empty_argument_is_preserved(self) -> None:
        observed = subprocess.CompletedProcess([], 2, "", "Error: provide a non-empty path.\n")
        with patch.object(harness.subprocess, "run", return_value=observed) as run:
            self.assertTrue(harness.run_case(self.binary, self.cwd, "empty",
                                             ["check", ""], "",
                                             "Error: provide a non-empty path.\n", 2))
            self.assertEqual(run.call_args.args[0][-1], "")


if __name__ == "__main__":
    unittest.main()
