## Context

See `proposal.md` — Why. The constraints that shape the approach, all measured
on this machine:

- foot 1.27.0 exports `COLORTERM=truecolor` itself. The `COLORTERM` blocks in
  `env.fish` and `.bashrc` are guarded on the variable being unset, so under
  foot they never fire. They still matter for herdr and Windows Terminal and
  stay as they are.
- fish 4.6.0 emits 24-bit for a hex colour: `set_color f62b5a` produces
  `ESC[38;2;246;43;90m`. No `fish_term24bit` opt-in is needed.
- The `foot` terminfo entry carries `colors#0x100` and none of `RGB`, `Tc`,
  `setrgbf`, `setrgbb`. Only `foot-direct` carries `RGB` and
  `colors#0x1000000`. Both are `ncurses-base`'s, not foot's own package.
- `LS_COLORS` today draws on eleven distinct palette slots. Those slots resolve,
  under foot 1.27's shipped starlight-V4 palette, to the hex values this change
  writes down.
- `vivid` is not in Fedora's repositories and `cargo` is not installed here.
- No existing spec names `LS_COLORS`.

## Goals / Non-Goals

**Goals:**

- One tracked file holds the listing's colours, in hex, readable.
- The colour vocabulary on screen is unchanged.
- fish and bash agree, as they already do on the rest of the environment.

**Non-Goals:**

- Restating foot's sixteen palette slots in `foot.ini`. Once nothing this
  configuration emits asks for a slot by index, their values stop mattering, and
  writing them down would create a second place to keep in step with no reader.
- A theme. Colours are transcribed, not chosen.

## Decisions

### `vivid` generates `LS_COLORS`, not a rewrite of `dircolors` output

`dircolors` speaks only in palette indices; there is no flag that makes it emit
`38;2`. The alternatives were to post-process its output — extend the existing
`01;3X` → `01;9X` substitution into a full index-to-hex mapping — or to write
the `LS_COLORS` string out by hand.

Post-processing keeps `dircolors` as the source of the extension list, but the
mapping table has to live somewhere, and it would be a `string replace` chain
over sixteen slots in `env.fish` and a parallel `${VAR//}` chain in `.bashrc`:
two copies of a table, in two languages, that no one can read as colours.
Writing the string by hand is one 4 KB literal, twice.

`vivid` separates the two concerns the way this change needs: the extension
database is its own file, the colours are a YAML theme in `RRGGBB`, and its
output is already `38;2`. Cost of the dependency is bounded — see the fallback
below.

### The theme is tracked and transcribed from foot's shipped palette

`.config/vivid/themes/starlight.yml`, selected as `vivid generate starlight`;
`vivid` reads `themes/` under `$HOME/.config/vivid`. Its `colors:` block names
foot 1.27's starlight-V4 values, which is what the palette indices in today's
`LS_COLORS` resolve to:

| role | today | hex |
| --- | --- | --- |
| directory | `01;94` bright blue | `5dc5f8` |
| symlink | `01;96` bright cyan | `24dfc4` |
| executable | `01;92` bright green | `35d450` |
| archives | `01;91` bright red | `ff4d51` |
| media | `01;95` bright magenta | `feabf2` |
| audio | `00;36` cyan | `13c299` |
| backup, `~` and `#` | `00;90` bright black | `616161` |
| device background | `40` black | `242424` |

A bundled theme was the obvious alternative and is rejected for the stated
scope: every one of the thirty-five would move the colours.

### Categories `dircolors` leaves plain stay plain

`vivid`'s database has groups `dircolors` has no equivalent for — `text`,
`markup`, `programming`, `office`, `unimportant`. Today those files render in
the default foreground. The theme leaves them `{}`, so they still do.

This is the one place the two mechanisms could have diverged and the reason to
choose deliberately: colouring source files green would introduce no new colour,
but it would be a look this configuration has never had, and it would put source
files and executables in the same green. Turning any of them on later is one
theme entry.

What does change, unavoidably and by design, is which extension falls in which
group: that comes from `vivid`'s database rather than `dircolors`'s list. The
colours are the same; a given file may be reached by a different one of them.
`specs/terminal-colors/spec.md` allows exactly this and no more.

### `vivid` is optional, and the fallback is today's code

Guarded with `type -q vivid` in fish and `command -v` in bash, matching
`direnv.fish` and `fzf.fish`. Where it is absent the existing `dircolors -b`
build runs instead, including the `01;3X` → `01;9X` rewrite — that workaround
stays meaningful on exactly the path where colours are still palette indices.

So the dependency buys the 24-bit naming and costs nothing when missing, which
is what puts it under **Optional** in the README rather than **Required**.

### Installed from the release tarball into `~/.local/bin`

Not packaged for Fedora, and no Rust toolchain here, so the remaining routes are
a release binary or building one. `sharkdp/vivid` v0.11.1 publishes
`vivid-v0.11.1-x86_64-unknown-linux-gnu.tar.gz`, sha256
`7060e45ba1fc5b25d521704e65d2e5d92c1b219c06b7183ec120a87e1fc376d7`, holding a
single static-enough binary; the filetype database and the bundled themes are
compiled into it, so the tarball is the whole install. `~/.local/bin` is already
prepended to `PATH` by `env.fish`, and `.local/` is denylisted, so nothing of it
is tracked — the same shape the `openspec` CLI already has in the README.

### Generation runs on every shell, uncached

Measured, twenty runs each: `vivid generate` 2.5 ms, `dircolors -b` 0.7 ms. The
1.8 ms is not worth a cache file, its staleness rule, and the failure mode where
the cache outlives the theme it came from.

### `fish_color_*` go in a new `conf.d/colors.fish` as globals

`conf.d/tide.fish` is the precedent for a prompt-appearance file outside the
four named categories, and `fzf.fish` cites it as such. Globals, not universals,
for the reason `env.fish` already gives about `fish_add_path -g`: a universal
lands in `fish_variables`, which is gitignored, and would then outlive an edit
to the tracked file.

The values are the hex of the named defaults fish uses today, read off fish 4.6
rather than assumed. Note those variables now hold two elements — the colour and
a `--theme=default` marker — so the current value is the first element.

`fish_pager_color_*` are set on the same basis.

### `.bashrc` gets the same treatment, including its prompt

`.bashrc` keeps a deliberate copy of the environment block, and its `PS1` names
`01;92` and `01;94` for the same reason `LS_COLORS` did. Both become hex.
Leaving bash behind would put the divergence exactly where the README says it
must not be.

### Terminfo is left alone

Neither `TERM=foot-direct` nor a `tic`-compiled `~/.terminfo` entry adding `RGB`
to `foot`. `TERM` travels over `ssh` and is read against the remote host's
terminfo database: `foot` is already missing on many hosts, `foot-direct` on
more, and a locally extended entry on all of them. `COLORTERM` does not travel
that way and a program that ignores it loses colours rather than gaining
garbage.

The cost is that a program reading depth from terminfo stays at 256 colours.
`htop` is the only one installed. Accepted, and written into the spec so it is
not quietly revisited.

## Risks / Trade-offs

- **`vivid`'s database groups an extension differently from `dircolors`, and a
  file changes colour** → Bounded to files whose colour was already one of the
  eight above; the spec permits it explicitly. Anything surprising is one entry
  in a tracked YAML file.
- **A machine gets `vivid` at a version whose database or theme schema has
  moved** → The theme is schema-checked at every shell start by `vivid` itself;
  a rejected theme prints to stderr, which a shell start would show. The
  fallback is unaffected, since it does not read the theme.
- **The 24-bit values are transcribed from foot's shipped palette, so a foot
  release that reshuffles starlight leaves them stale** → They are stale in the
  sense of no longer matching, not broken: the colours stay exactly what is
  written down, which is the point of the change. The table above and the
  theme's comments record where the numbers came from.
- **`vivid` runs before the interactivity guard, so scripts pay 2.5 ms** →
  Measured and accepted; the `dircolors` build it replaces was already there.
- **A tarball install has no update path** → Same as the `openspec` CLI and
  `herdr`, and the README already documents that class.

## Migration Plan

No state to migrate. `LS_COLORS` and `fish_color_*` are recomputed at every
shell start, so the change takes effect in the next shell and reverting the
files reverts the colours.

`foot.ini` is the exception and already has its rule recorded in the file: the
server reads it once at startup, so the `[colors]` section needs
`systemctl --user restart foot-server.service` before a new window shows it.
