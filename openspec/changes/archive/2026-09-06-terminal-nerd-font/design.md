## Context

See `proposal.md` — Why. The constraints that shape the approach, none of which are motivation:

- **The session runs inside the thing being reconfigured.** foot reads `foot.ini` once, when `foot --server` starts; new `footclient` windows inherit that reading. Applying a font change means `systemctl --user restart foot-server.service`, which terminates every window the server owns — including whatever shell is running the change. `pstree` on this machine confirms it: `systemd → foot → fish → claude`.
- **The font files cannot be tracked.** Block 4 of `.gitignore` denies `.local/`, and the patched release is 40M of binary in any case. A checkout carries the terminal's configuration but nothing the configuration names.
- **The distribution packages a decoy.** Fedora ships `jetbrains-mono-fonts` 2.304. It is the unpatched upstream: same name, same glyphs a monospace font normally has, none of the Nerd Font ranges. A future reader searching the package manager for the font this repository names will find it and install the wrong thing.
- **alacritty is invisible to every mechanism here.** Installed as a system package, configured in an untracked file, named in no spec and no binding. Nothing in the repository knows it exists.

## Goals / Non-Goals

**Goals:**

- One font family, named in one place, resolving to patched faces.
- An install a rebuild can reproduce from tracked documentation alone.
- A restart procedure that does not depend on the operator noticing that it kills their own terminal.

**Non-Goals:**

- Font configuration for anything but the terminal. waybar names its own stack in `style.css` (`Noto Sans Mono`, then the Font Awesome families) and is not touched; fuzzel and swaylock keep their defaults.
- A fontconfig alias layer. See the decision below.
- Replacing alacritty's `Shift+Return` binding in foot. It is recorded as lost in the proposal and in the spec, not re-implemented.
- Ligature configuration. JetBrains Mono has ligatures and foot does not enable them by default; that stays as it is.

## Decisions

**Install the patched release, not the distribution package, and not a fontconfig alias.**

Three ways to get Nerd Font glyphs into the terminal:

1. Install the patched release and name its family. Chosen.
2. Install `jetbrains-mono-fonts` and add a fontconfig fallback rule pointing the missing ranges at a separate symbols-only font (`nerd-fonts-symbols` style). This works and is how some distributions prefer it, but it puts the glyph coverage in a file the repository would also have to track and reason about, and the failure mode when the fallback misses is the same box with one more layer to look through.
3. Point `foot.ini` at a generic family and let fontconfig decide. Rejected outright — it is what produced the current broken state.

Option 1 keeps the whole decision in one line of `foot.ini` and one directory. The cost is that the font is a manual per-user install with no package manager to update it, which this repository already accepts for `bob`, `herdr` and the OpenSpec CLI.

**Per-user under `.local/share/fonts/`, not system-wide.**

`/usr/share/fonts/` needs root and puts a file outside the repository's root that nothing here records. `.local/share/fonts/` is picked up by fontconfig without configuration, matches how every other non-packaged tool here is installed, and is reproducible by a user with no administrative access. It is already denied by the ignore policy, so the install adds nothing to `git status` — which is worth stating explicitly, because 40M appearing in `$HOME` with a clean `git status` otherwise looks like something went wrong.

**Keep one family of six.**

The release ships base, `Mono` and `Propo`, each with a no-ligature `NL` twin. In a terminal the distinction is width: the base and `Propo` families draw icon glyphs at double width, so a status line that assumes one cell per glyph misaligns. `Mono` draws them in a single cell. The `NL` twins differ only in ligatures, which the ligature-carrying families can turn off at the terminal instead.

Sixteen faces, 40M. The alternative — keep all 96, 233M — was considered and rejected: the extra families are not merely unused, they are *wrong* for this use, and leaving them installed means a later configuration can name `JetBrainsMono Nerd Font` (the base family, an easy mistake, one word shorter) and get a subtly broken grid with no error.

**Name the family in `foot.ini`; leave the size at 11.**

The size is unchanged deliberately, so that if the session looks wrong after the restart, the family is the only variable. JetBrains Mono and Adwaita Mono do not have identical metrics, so cell dimensions shift slightly at the same nominal size; that is expected and is not a reason to retune the size in this change.

**Remove alacritty rather than adopt or ignore it.**

Adopting it means a `.gitignore` allowlist entry, a README entry, and a spec requirement for a terminal nothing opens — permanent surface for no capability. Ignoring it means leaving a terminal one keystroke away that renders the prompt and Neovim as boxes, whose fix would live in an untracked file. Removal is a `dnf remove` and a directory deletion, and the retirement record makes returning it a deliberate act rather than an accident.

`dnf remove alacritty` also removes `libxkbcommon-x11` as a then-unused dependency. That library is X11 keymap handling; niri provides X11 through `xwayland-satellite`, which does not link it, and nothing else on the machine pulled it in. 8 MiB total.

**Order the work so the disruptive step is last and expected.**

The font install, the trim, the cache rebuild and the alacritty removal are all non-disruptive and independently verifiable — `fc-match` answers correctly before `foot.ini` is touched at all. Editing `foot.ini` is also non-disruptive, because the running server has already read the old file and will not re-read it. Only the restart is disruptive, and by the time it runs, everything it depends on has been verified. This means the restart is a single reversible act at a known point rather than a step buried in the middle.

## Risks / Trade-offs

- **Restarting the foot server kills the terminal running the change, including this session.** → Do it last, after every other step is verified and committed. `systemd` owns `foot-server.service`, so the restart survives its own client dying and the server comes back; the windows do not. Treat the terminal contents as lost and commit before restarting.
- **A verified `fc-match` does not prove the terminal renders it.** fontconfig resolving `charset=e0b0` says the file is installed and selectable, not that foot picked it. → After the restart, confirm in a window: the prompt draws icons rather than boxes, and Neovim's file explorer does too.
- **The font is a manual install with no update path.** No package manager tracks it; nerd-fonts releases will move on without this machine. → Accepted, and identical to `bob` and `herdr`. The README entry names the release version so a reader can tell what they have.
- **A rebuild that skips the README entry produces a session that looks broken rather than incomplete.** `foot.ini` names a font that does not exist, fontconfig substitutes something, and the result is boxes with no error anywhere. → The spec makes the documentation entry a requirement with its own scenarios, rather than leaving it as a courtesy.
- **Removing alacritty removes a fallback terminal.** If foot's server unit fails to start, there is now no second terminal in the session. → A VT is still reachable, and `foot` runs standalone without the server. The fallback was never configured or bound, so it was not a fallback in practice.
- **`libxkbcommon-x11` leaving could surface in an X11 client nothing has tested.** → It is pulled back by any package that needs it, and `dnf` reported it unused. Reinstalling it is one command if an X11 client complains.

## Migration Plan

1. Trim the installed font tree to the `Mono` faces; rebuild the font cache.
2. Verify with `fc-list` (one family reported) and `fc-match` against a Nerd Font codepoint.
3. Remove the alacritty package and its configuration directory.
4. Update `foot.ini`, `README.md`, and the `retired-tooling` spec.
5. Commit.
6. Restart `foot-server.service` — this closes every terminal window.
7. In a new window, confirm the prompt and Neovim draw icons.

**Rollback:** restore the `font=Adwaita Mono:size=11` line and restart the server; the session is back to its current state with an unused font tree in `.local/share/fonts/`. alacritty is `dnf install alacritty` and a four-line configuration file, both recorded in this change.

## Open Questions

None. The two decisions that would have changed the specs or the task breakdown — whether alacritty is adopted, retired or left alone, and which faces are installed — were settled before the specs were written.
