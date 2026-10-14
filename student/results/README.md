# Results

One folder per issue, named after the issue's task ID and branch, e.g.
`B01-nonzero-exit/`. Link the folder from the issue and from its pull request.

Each folder starts with a `README.md` like this:

```markdown
# B01 - Failing tests must return a nonzero exit status

Issue: #12   Branch: b01-nonzero-exit   Revision: <git rev-parse HEAD>

## Configuration
Build: workbench / finalized (-keep)   Assertions: pre/post/check/invariant on
Compiler: ISE_C_COMPILER=<value>   Callbacks: <which>   Chunks: <sizes>

## Runs
| # | Command | Input (or sha256) | Expected | Actual | Exit |
|---|---|---|---|---|---|
| 1 | `...` | `...` | nonzero | 0 | 0 |

## Observations
Facts only.

## Possible explanations
Clearly marked as not yet confirmed.
```

Put the full logs next to it (`before.log`, `after.log`, ...). Store byte-exact
inputs, such as invalid UTF-8, as files and never as copied text.
