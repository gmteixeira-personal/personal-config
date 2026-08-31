## Context

See proposal.md — Why. What shapes the approach is where direnv 2.37.1 actually reads this setting from, which is not where its documentation first suggests.

direnv separates its two output paths in the source: `log_status` prints the routine lines (`loading …`, `export …`), `log_error` prints diagnostics. Only the first is filterable, which is exactly the cut this change wants. It was verified empirically rather than taken from the docs, because the obvious mechanism does not work on this version:

| Attempt | Result |
| --- | --- |
| `DIRENV_LOG_FORMAT=""` in the environment | both lines still printed |
| `DIRENV_LOG_FORMAT="XX %s"` in the environment | still `direnv: loading …` — the variable is not honoured at all |
| `log_filter = "^$"` in `direnv.toml` | routine lines gone, errors kept |

So the environment variable is a dead end here and the config file is the only working lever. This matters beyond the choice of file: an implementation that sets the variable would look correct, would be committed, and would change nothing.

## Goals / Non-Goals

**Goals:**

- Nothing on the success path, in both shells, on every machine that clones this.
- Errors unchanged — same text, same exit status, same trigger conditions.

**Non-Goals:**

- Changing when environments activate, or anything in `direnvrc`.
- Suppressing direnv's own commands. `direnv allow` and `direnv status` are run deliberately and should answer.

## Decisions

**Filter `log_status` with `log_filter = "^$"` rather than blanking the log format.** `log_filter` is a regular expression matched against each status message; only matches are printed. `^$` matches the empty string alone, which no real message is, so every status message is dropped and the mechanism stays legible — the intent reads as "print nothing routine" rather than as a format string that happens to render empty. Blanking `log_format` was the first choice and does not work on 2.37.1 at all (see Context), which settles it.

Errors are untouched by this because `log_error` does not consult the filter. Verified on both failure paths: a blocked `.envrc` still prints its `direnv allow` line and exits 1, and `layout venv` with no `.venv` still prints the line naming the path.

**Put it in `.config/direnv/direnv.toml`, tracked.** `direnvrc` already lives in that directory and is already allowlisted, so this follows a path the ignore policy has already ruled on. A machine-local setting would have to be re-made on every clone, and the noise would be back on each new machine — which is the same reason `conf.d/tide.fish` exists rather than relying on `fish_variables`.

**Do not silence the shell hook instead.** Redirecting the hook's output in `conf.d/direnv.fish` would work in fish and leave bash noisy, would suppress errors along with status lines, and would put shell-specific plumbing where the capability requires there be none. The setting belongs to direnv, and applies to both shells at once because of that.

## Risks / Trade-offs

- **A silent success path gives no confirmation that direnv ran.** → The prompt is the confirmation: it names the environment and the interpreter version, which is a stronger statement than `loading .envrc` and is on screen continuously rather than once. `direnv status` remains for the question the prompt does not answer.
- **`log_filter` is matched against message text, so a future direnv could route something worth reading through `log_status`.** → Errors are a separate path and stay visible; a status message that mattered would be a change in direnv's own behaviour, and the filter is one line to relax if that happens.
- **The setting is invisible once it works: a later reader sees a silent shell and no obvious cause.** → The file is tracked and carries a comment saying what is filtered and what deliberately is not, which is where someone looking for the cause will land.
