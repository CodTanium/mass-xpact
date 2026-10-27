"""Observe excluded W3C inputs without changing the official conformance profile.

Run from any directory with --suite-dir, one or more --build NAME=build.json,
and a fresh --output-dir. Uses verified, freshly built W3C executables. Results
are diagnostic observations, never additional conformance passes or JUnit tests.
"""

import argparse
from collections import Counter
import csv
from dataclasses import replace
import hashlib
import json
from pathlib import Path
import re
import sys

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "scripts"))
import build_implementations as builds
import run_w3c_conformance as w3c


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--suite-dir", type=Path, required=True)
    parser.add_argument("--build", action="append", required=True, metavar="NAME=BUILD_JSON")
    parser.add_argument("--output-dir", type=Path, required=True)
    parser.add_argument("--timeout", type=float, default=3.0)
    args = parser.parse_args()
    if not 0 < args.timeout < float("inf"):
        parser.error("--timeout must be positive and finite")
    suite = args.suite_dir.resolve()
    cases = [case for case in w3c.load_catalog(suite) if case.skip_reason]
    original_hashes = {case.path: sha256(case.path) for case in cases}
    engines = {}
    for argument in args.build:
        name, separator, manifest = argument.partition("=")
        if not separator or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.-]*", name) or name in engines:
            parser.error("Each --build needs a distinct NAME=BUILD_JSON")
        metadata = json.loads(Path(manifest).read_text(encoding="utf-8"))
        executable = Path(metadata["executable"])
        if (metadata["status"] != "verified" or metadata["profile"] != "w3c"
                or metadata["implementation"] != "xpact"
                or metadata["executable_sha256"] != sha256(executable)
                or metadata["build_inputs_sha256"] != builds.source_fingerprint(REPO, "xpact", "w3c")):
            raise ValueError("Build no longer matches the current source/executable: " + name)
        engines[name] = metadata
    output = args.output_dir.resolve()
    if output == suite or output.is_relative_to(suite):
        raise ValueError("Output must be outside the suite")
    output.mkdir(parents=True, exist_ok=False)
    state = {"status": "running", "official_profile": w3c.PROFILE,
             "excluded_cases": len(cases), "suite_directory": str(suite),
             "builds": engines, "timeout_seconds": args.timeout,
             "warning": "Original skips are bypassed for observation only; catalog expectations for other versions/editions are inapplicable."}
    (output / "run.json").write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
    rows = []
    try:
        for name, metadata in engines.items():
            work = output / name
            work.mkdir()
            for index, case in enumerate(cases):
                if sha256(case.path) != original_hashes[case.path]:
                    raise ValueError("Input changed before probe: " + case.id)
                result = w3c.run_case(replace(case, skip_reason=""), name,
                                      Path(metadata["executable"]), args.timeout, work,
                                      diagnostic_dir=work / str(index))
                rows.append({"engine": name, "case_id": case.id,
                             "path": case.path.relative_to(suite).as_posix(),
                             "kind": case.kind, "recommendation": case.recommendation,
                             "original_skip_reason": case.skip_reason,
                             "catalog_expected": case.expected, "observed": result.actual,
                             "execution": "error" if result.status == "error" else "normal",
                             "exit_code": result.exit_code, "elapsed_ms": result.elapsed_ms,
                             "diagnostic": result.message})
                if (index + 1) % 200 == 0:
                    print(name, index + 1, "/", len(cases), flush=True)
            if metadata["executable_sha256"] != sha256(Path(metadata["executable"])):
                raise ValueError("Executable changed during probe: " + name)
        if any(sha256(path) != digest for path, digest in original_hashes.items()):
            raise ValueError("An input changed during the probe")
        state["status"] = "complete"
        state["observations"] = [{"engine": name, "skip_reason": reason,
                                  "kind": kind, "observed": actual, "count": count}
                                 for (name, reason, kind, actual), count in
                                 Counter((r["engine"], r["original_skip_reason"], r["kind"], r["observed"])
                                         for r in rows).items()]
    except Exception as error:
        state.update(status="failed", error=str(error))
        raise
    finally:
        if rows:
            with (output / "observations.tsv").open("w", encoding="utf-8", newline="") as stream:
                writer = csv.DictWriter(stream, fieldnames=list(rows[0]), delimiter="\t")
                writer.writeheader()
                writer.writerows(rows)
        (output / "run.json").write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
    print("Diagnostic observations:", output, flush=True)


if __name__ == "__main__":
    main()
