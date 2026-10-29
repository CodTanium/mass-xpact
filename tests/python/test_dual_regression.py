"""Verify the dual regression lane's expectations, chunkings, judging and reports without Eiffel."""

import importlib.util
from pathlib import Path
import sys
import tempfile
import unittest
from unittest import mock


REPO = Path(__file__).resolve().parents[2]
SCRIPTS = REPO / "scripts"
sys.path.insert(0, str(SCRIPTS))
SPEC = importlib.util.spec_from_file_location("run_dual_regression", SCRIPTS / "run_dual_regression.py")
runner = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = runner
SPEC.loader.exec_module(runner)


class ExpectationTests(unittest.TestCase):
    def test_escaping_matches_the_eiffel_trace(self):
        # DR_TRACE.escaped keeps printable ASCII except \ and |.
        self.assertEqual(runner.escaped(b"a|b\\c\r\n\xc3\xa9~ "), "a\\x7cb\\x5cc\\x0d\\x0a\\xc3\\xa9~ ")

    def test_case_names_are_unique_and_inputs_are_bytes(self):
        cases = runner.cases()
        names = [case[0] for case in cases]
        self.assertEqual(len(names), len(set(names)))
        self.assertTrue(all(isinstance(case[2], bytes) for case in cases))

    def test_accepted_cases_have_events_and_rejected_cases_have_none(self):
        for name, _, _, accepted, events in runner.cases():
            with self.subTest(name=name):
                self.assertEqual(accepted, events is not None)
                if accepted:
                    self.assertTrue(events[0].startswith("start:") and events[-1].startswith("end:"))

    def test_every_utf8_sequence_and_place_is_present(self):
        names = {case[0] for case in runner.cases() if case[1] == "utf8"}
        self.assertEqual(len(names), 7 * 6)
        self.assertIn("utf8-ff-cdata", names)
        self.assertIn("utf8-valid-e9-name", names)

    def test_lifecycle_steps_are_unique(self):
        steps = [step for step, _, _ in runner.LIFECYCLE]
        self.assertEqual(len(steps), len(set(steps)))


class ChunkingTests(unittest.TestCase):
    def test_chunkings_of_a_short_input(self):
        self.assertEqual(runner.chunkings(b"<a/>"),
                         ["whole", "split@1", "split@2", "split@3", "bytes", "bytes-final"])

    def test_empty_input_runs_whole_only(self):
        self.assertEqual(runner.chunkings(b""), ["whole"])

    def test_one_byte_input_has_no_bytes_final(self):
        self.assertEqual(runner.chunkings(b"x"), ["whole", "bytes"])


class JudgeTests(unittest.TestCase):
    EVENTS = ["start:a", "end:a"]

    def test_pass_needs_verdict_and_exact_events(self):
        self.assertEqual(runner.judge(True, self.EVENTS, "ACCEPT", "start:a | end:a"), "PASS")
        self.assertEqual(runner.judge(True, self.EVENTS, "ACCEPT", "start:a"), "WRONG-EVENTS")
        self.assertEqual(runner.judge(True, self.EVENTS, "REJECT", ""), "WRONG-VERDICT")

    def test_rejections_are_judged_on_the_verdict_only(self):
        self.assertEqual(runner.judge(False, None, "REJECT", "start:a"), "PASS")
        self.assertEqual(runner.judge(False, None, "ACCEPT", ""), "WRONG-VERDICT")

    def test_crash_and_timeout_are_never_pass(self):
        self.assertEqual(runner.judge(False, None, "CRASH", ""), "CRASH")
        self.assertEqual(runner.judge(True, self.EVENTS, "TIMEOUT", ""), "TIMEOUT")


class TraceParsingTests(unittest.TestCase):
    def test_parse_lines_keeps_only_complete_marked_lines(self):
        output = ("noise\nXPACT_TRACE\twhole\tACCEPT\tstart:a | end:a\t\n"
                  "XPACT_TRACE\tbroken\tACCEPT\n"
                  "XPACT_TRACE\tbytes\tREJECT\t\tstatus 0, code 3\n")
        rows = runner.parse_lines(output, "XPACT_TRACE")
        self.assertEqual(rows, {"whole": ("ACCEPT", "start:a | end:a", ""),
                                "bytes": ("REJECT", "", "status 0, code 3")})

    def test_a_crash_is_isolated_to_its_chunking(self):
        calls = []

        def fake_run(executable, arguments, cwd, timeout):
            calls.append(arguments)
            if "--chunking" not in arguments:
                return 3, "XPACT_TRACE\twhole\tACCEPT\tstart:a | end:a\t\n", "crash"
            if arguments[-1] == "whole":
                return 0, "XPACT_TRACE\twhole\tACCEPT\tstart:a | end:a\t\n", ""
            if arguments[-1] == "bytes":
                return None, "", "timeout"
            return 3, "", "contract violated"

        with mock.patch.object(runner, "run_exe", fake_run):
            result = runner.trace_case("exe", Path("f.xml"), ["whole", "split@1", "bytes"], Path("."), 5)
        self.assertEqual(result["whole"], ("ACCEPT", "start:a | end:a", ""))
        self.assertEqual(result["split@1"][0], "CRASH")
        self.assertEqual(result["bytes"][0], "TIMEOUT")
        self.assertEqual(len(calls), 4)


class ReportTests(unittest.TestCase):
    def test_reports_list_failures_and_build_errors(self):
        rows = [{"build": "xpact/assertions-on", "case": "c", "group": "g", "chunking": "whole", "input": "x",
                 "expected": "ACCEPT", "verdict": "ACCEPT", "result": "PASS", "expected_events": "e",
                 "events": "e", "error": ""},
                {"build": "xpact/assertions-on", "case": "d", "group": "g", "chunking": "bytes", "input": "y",
                 "expected": "ACCEPT", "verdict": "REJECT", "result": "WRONG-VERDICT", "expected_events": "e",
                 "events": "", "error": "status 0"}]
        lifecycle = [{"build": "xpact/assertions-on", "step": step, "expected": "ACCEPT" if ok else "REJECT",
                      "verdict": "ACCEPT" if ok else "REJECT", "result": "PASS", "expected_events": "",
                      "events": "", "error": ""} for step, ok, _ in runner.LIFECYCLE]
        executables = {"xpact/assertions-on": {"source": {"revision": "a" * 40},
                                               "build": {"configuration": "finalized/assertions-on/msvc-x64"},
                                               "executable_sha256": "b" * 64}}
        with tempfile.TemporaryDirectory() as directory:
            run_root = Path(directory)
            runner.write_reports(run_root, rows, lifecycle, executables, {"xpact-core/assertions-on": "ec failed"})
            summary = (run_root / "summary.md").read_text(encoding="utf-8")
            self.assertIn("| xpact-core/assertions-on | build failed | ec failed | |", summary)
            self.assertIn("| xpact/assertions-on | 2 | 1 | 1 |", summary)
            self.assertIn("| xpact/assertions-on | d | 1 | WRONG-VERDICT | bytes | `-` | status 0 |", summary)
            self.assertEqual(len((run_root / "cases.tsv").read_text(encoding="utf-8").splitlines()), 3)


if __name__ == "__main__":
    unittest.main()
