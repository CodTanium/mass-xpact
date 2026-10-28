# Issue #88: Enable verified WSL Eiffel GCC benchmark settings by default

Archived from <https://github.com/andersoxie/xpact/issues/88> on 2026-10-28 21:36 UTC.

| | |
|---|---|
| State | open |
| Author | andersoxie |
| Created | 2026-10-25 07:06 |
| Closed |  |
| Labels | - |
| Milestone | - |

## Description

The WSL Eiffel/GCC benchmark stage currently defaults to disabled with empty distribution and Eiffel environment values, so future builds require manual parameter entry. Enabling the stage without configuring the environment failed with `Required Linux tool 'ec' was not found on PATH`.

Set these defaults in both `ci/Jenkinsfile.windows-phase1` and `ci/Jenkinsfile.all-tests`:

- `RUN_WSL_EIFFEL_BENCHMARKS=true`
- `WSL_DISTRIBUTION=Ubuntu`
- `WSL_EIFFEL_ENVIRONMENT=/mnt/c/Users/ander/Documents/xpact/build/wsl-toolchain/eiffel-env.sh`

Preserve parameter overrides for other hosts and document when Jenkins refreshes the defaults.

Jenkins build #74 already validated these exact parameter values: the full build finished SUCCESS; 14 runner tests and 31 published WSL cases passed, with 30 benchmark measurements. That run predates the defaults change and does not verify loading the new Jenkinsfile defaults.

The configuration targets the existing built-in Windows agent. Other hosts must override the distribution and environment path. Defaults take effect when Jenkins executes the updated Jenkinsfile; already submitted build values remain unchanged.
