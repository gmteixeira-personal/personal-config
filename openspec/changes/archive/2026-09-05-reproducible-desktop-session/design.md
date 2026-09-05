## Context

See proposal.md — Why. Constraints that shape the approach:

- Noctalia reads `*.toml` from its config directory (`~/.config/noctalia/`) and then applies `~/.local/state/noctalia/settings.toml` as overrides. `.config/` is allowlistable; `.local/` is denylisted in the ignore policy's block 4 along with the other bulk machine-local trees.
- Its settings UI writes to the state file, not the config directory. The config directory is currently empty.
- `noctalia config export` reads the same stack the shell does, in `merged` and `full` modes, and `noctalia config validate` checks a result.
- The README already carries a **Bootstrap a new machine** procedure and a three-group required-software list whose rules are specified in `dotfiles-repo`.

## Goals / Non-Goals

**Goals:**

- A checkout that yields the same session, not a session-shaped hole.
- No restore step on a fresh machine — the declaration should apply by being read.
- An honest record of where the declaration can drift, rather than a claim it cannot.

**Non-Goals:**

- Making the tracked declaration authoritative on this machine. That would mean fighting the settings UI for ownership of the state file.
- Tracking `~/.local/state/noctalia/` or narrowing the `.local/` denylist. The denylist is right; the answer is a declaration, not an exception.
- Capturing theme templates, community palettes or the wallpaper asset. Those are content the packages already carry or that the shell regenerates.

## Decisions

**Declare in the tool's own config layer, not in a neutral file.**
The declaration goes to `.config/noctalia/settings.toml`. On a machine with no state file — which is every fresh machine — Noctalia reads it as configuration and the session comes up themed and laid out with nothing else done. The alternative, parking an export somewhere neutral and documenting a copy step into the state directory, was rejected: it makes correctness depend on someone remembering a command, and it writes into a directory the policy denylists precisely because the repository should not be reaching into it.

**Accept that state shadows the declaration, and say so.**
This was measured rather than assumed. With a key present in both layers, the state value wins; with a key present only in the config layer, the config value applies. So on this machine the declaration is inert for any key the settings UI has written, and the two can drift without symptom. Two responses were possible: fight it, by keeping the state file empty and forbidding the UI, or record it. Recording it is the honest option — the drift is real, it is invisible locally, and the only defence is refreshing the declaration when settings change, which the README will say and the spec requires.

**Export the effective configuration, not the state file verbatim.**
`noctalia config export` is the supported reader of the same stack the shell uses, and its output is a valid input. Copying `settings.toml` byte-for-byte would carry `config_version` and whatever else the UI writes for its own bookkeeping. The export is checked for home-directory paths before it is tracked; the wallpaper it names is under `/usr/share/`, which is package content and portable.

**Name the session software in the README's existing groups rather than adding a section for it.**
`dotfiles-repo` already specifies what those groups mean and what each entry must say. A parallel list for the session would drift from the rules that govern the first one. niri, foot and noctalia are Required — tracked configuration exists for each. `xwayland-satellite` is Required with a precise reason: without it X11 clients do not run under niri at all. fuzzel, swaylock and waybar are Optional, being superseded but still installed and still reachable if the shell is abandoned.

## Risks / Trade-offs

- **The declaration goes stale the first time settings are changed in the UI.** → Inherent to a layer the tool owns. Mitigated by a spec requirement and a README instruction to re-export, and by the export being one command with a validator.
- **The declaration is inert on the machine it came from, so it is never exercised where it is written.** → It is exercised by `noctalia config validate`, and its real test is the next machine. Worth re-exporting and validating rather than assuming.
- **`config_version = 14` pins a schema.** → A future Noctalia may migrate it. The export is regenerated from a running shell rather than hand-maintained, so a migration is picked up by re-exporting.
- **Optional entries for waybar, fuzzel and swaylock will read oddly to someone who never used them.** → Each says what is lost, and `desktop-shell` already records that they are superseded rather than retired.
