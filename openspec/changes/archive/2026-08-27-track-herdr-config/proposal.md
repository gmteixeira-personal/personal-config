## Why

herdr is the terminal workspace manager these sessions run inside, and its configuration was never part of this repository. The ignore file denies by default, and no allowlist entry ever named `.config/herdr/config.toml`, so when this configuration was restored onto a new machine the file did not come with it. herdr wrote a fresh one, with no `[keys]` section at all, and the prefix reverted to the shipped `ctrl+b`.

Nothing about that failure was visible until the prefix was pressed. The tool was installed, its config file existed, and its content was plausible — it was simply not the configuration that had been built up on the previous machine.

The directory it lives in is why the entry was easy to omit: alongside `config.toml` it holds two unix sockets, three log files, a session record and a plugin lock, none of which belong anywhere near a public remote.

## What Changes

- Allowlist `.config/herdr/config.toml` — that one file, not the directory — in block 3 of the ignore file.
- Restore the prefix binding as `ctrl+f` in a `[keys]` section, replacing the shipped `ctrl+b`.
- Leave every other path under `.config/herdr/` ignored: the client and server sockets, the three logs, `session.json`, and `.plugins.lock`.

## Capabilities

### Modified Capabilities

<!-- None. -->

### New Capabilities

- `herdr-config`: which part of herdr's directory is configuration that travels with this repository and which part is machine-local runtime state, and the prefix key that configuration fixes.

## Impact

- One line in `.gitignore`; one file newly tracked; one `[keys]` section in it.
- The prefix takes effect through herdr's own config reload, without restarting the server or losing a session.
- Every future herdr preference — theme, status indicators, toast delivery — now travels by default, because the file carrying them is tracked.
- A prefix key is captured by herdr before the program in the pane sees it, so `ctrl+f` is not delivered to anything running inside a pane. The shipped `ctrl+b` had the same property.
