"""Run the native DLL checker on every in-profile W3C case that uses external entities."""
import importlib.util
import json
import sys
import tempfile
from collections import Counter
from pathlib import Path

runner_path, suite_dir, out_dir = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
checkers = dict(arg.split("=", 1) for arg in sys.argv[4:])
spec = importlib.util.spec_from_file_location("runner", runner_path)
runner = importlib.util.module_from_spec(spec)
sys.modules["runner"] = runner
spec.loader.exec_module(runner)

cases = [c for c in runner.load_catalog(suite_dir) if not c.skip_reason and c.entities]
print("in-profile cases with external entities:", len(cases))
out_dir.mkdir(parents=True, exist_ok=True)
summary = {}
with tempfile.TemporaryDirectory(prefix="dll-", dir=out_dir) as work:
    for engine, checker in checkers.items():
        rows = [runner.run_case(c, engine, Path(checker), 30, Path(work),
                                extra_arguments=("--entity-root", str(suite_dir))) for c in cases]
        counts = Counter(r.status for r in rows)
        summary[engine] = dict(counts)
        print(engine, dict(counts))
        with (out_dir / f"{engine}.tsv").open("w", encoding="utf-8") as target:
            target.write("case_id\texpected\tactual\tstatus\texit_code\tmessage\n")
            for r in rows:
                target.write(f"{r.case_id}\t{r.expected}\t{r.actual}\t{r.status}\t{r.exit_code}\t"
                             f"{r.message.splitlines()[0] if r.message else ''}\n")
        for r in rows:
            if r.status != "passed":
                print("  ", r.case_id, r.expected, r.actual, r.status, r.exit_code, (r.message or "")[:120])
(out_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
