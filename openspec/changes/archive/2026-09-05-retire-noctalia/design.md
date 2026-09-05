## Context

See proposal.md — Why. What shaped the work is where the shell's output actually turned out to be, which was not where its own change described it.

`2026-09-05-noctalia-desktop-shell` accounted for two locations: `.config/noctalia/settings.toml`, tracked, and `~/.local/state/noctalia/`, denylisted. Both were correct. Neither was the whole surface. Auditing the machine for the string `noctalia` found it in nine places, seven of which belong to other programs:

| Path | What it was |
|---|---|
| `.config/gtk-3.0/gtk.css`, `.config/gtk-4.0/gtk.css` | one-line `@import url("noctalia.css")` |
| `.config/gtk-3.0/noctalia.css`, `.config/gtk-4.0/noctalia.css` | the imported palette |
| `.config/kdeglobals` | a whole Qt colour scheme, `ColorScheme=Noctalia` |
| `.config/kitty/kitty.conf`, `.config/kitty/themes/noctalia.conf` | a config file for a terminal not installed here |
| `.config/btop/themes/noctalia.theme` | a theme for a program not installed here |
| `.config/foot/themes/noctalia`, included from `foot.ini` | the terminal's colours |
| `.config/niri/noctalia.kdl`, included from `config.kdl` | the compositor's focus ring, border, tab indicator |

Every one of these was created on the day the shell was installed, and every one is untracked. Two of them — `.config/kitty/` and `.config/btop/` — are configuration directories for programs that are not installed on this machine at all; the shell created the directories in order to theme them. That is the concrete form of "too much stuff": not a heavy bar, but a theming engine writing files on behalf of programs nobody asked it about.

Reverting therefore has two halves that are easy to confuse. The tracked half is four files and is a normal diff. The untracked half is nine paths that no `git checkout` will ever restore or remove, and that no `git status` will ever show, because the ignore policy denylists all of them.

## Goals / Non-Goals

**Goals:**

- Return the session's bar, launcher and lock screen to waybar, fuzzel and swaylock, using the three lines the shell displaced.
- Keep foot exactly as it is, minus the colour theme the shell injected into it.
- Remove the shell's output from the machine, including what it wrote into other programs' directories.
- Record the retirement under `retired-tooling` so it cannot return quietly, and remove the `desktop-shell` capability rather than leave a spec describing a shell that is gone.

**Non-Goals:**

- Replacing the clipboard history. See Decisions.
- Configuring waybar, fuzzel or swaylock. They had no configuration before the shell and get none now; that is what made the revert three lines.
- Reverting `2026-09-05-seamless-window-appearance` or `2026-09-05-foot-terminal-on-niri`. Both are separate changes that happen to touch the same two files.
- Uninstalling the noctalia package. Nothing depends on it now and nothing starts it; whether it stays on disk is a package-manager decision, not a configuration one.

## Decisions

**Accept the loss of clipboard history rather than wire up `cliphist`.**

Clipboard history was the argument that carried the original change: a Wayland selection is owned by the client that set it, so copying in a terminal and closing it before pasting loses the text, and nothing here outlived that. Removing the shell brings that failure back, and it is a real cost rather than a neutral one.

Wiring `cliphist` instead would mean a `wl-paste --watch` entry in `config.kdl`, a binding, and a picker to render the list — which on this machine means fuzzel, so it would also mean fuzzel's first tracked configuration. That is a new capability with its own decisions, proposed on its own merits, not a rider on a revert. It is also not obviously wanted: the shell's history existed because the shell was there, not because a gap was being felt first.

So the loss is stated in the proposal rather than papered over, and `cliphist` is left installed and unwired, which is what `desktop-shell` already described it as.

**Remove `desktop-shell` outright rather than rewrite it around the separate components.**

The capability's own purpose sentence is "so that the session is served by one shell rather than four independent parts". Rewriting it to describe four independent parts would keep the name and invert the content. Every one of its six requirements is specifically about a single shell: that one program provides the furniture, that bindings address it over IPC rather than spawning, that it provides clipboard history natively, that the new binding it needed does not collide, and that the components it replaced stay installed against exactly this day. None survives the removal, including the last one, which was written to make the revert possible and is discharged by the revert happening.

What replaces it is nothing, deliberately. waybar, fuzzel and swaylock are three defaults reached by three lines in `config.kdl`; they are already covered by `graphical-session-startup` and by the required-software requirement in `desktop-session-declaration`. A capability asserting that a bar exists would be a spec with no decision in it.

**Leave the "untrackable state directory" requirements in `desktop-session-declaration` standing.**

Three of that capability's requirements — declaring settings that live in a denylisted state directory, refreshing a declaration that its state layer shadows, and keeping the declaration free of home paths and credentials — were written because of noctalia, and noctalia was their only instance. The temptation is to remove them with it.

They are written conditionally, though: "Where a tool keeps its settings in a directory the ignore policy denylists, and the tool also reads a configuration directory that the policy permits". With no such tool they are unexercised, not false. They also encode the more valuable half of the episode: the measurement that the state layer silently wins over the tracked declaration, and that the drift is only ever discovered on the next machine. That is a rule about this repository's ignore policy meeting tools in general, and it cost real work to establish. Deleting it as noctalia's leftovers would mean rediscovering it with the next such tool.

Only the two requirements that name a desktop shell concretely are touched. The required-software one listed it among its examples and is restated with the bar, the launcher and the lock screen in its place. The rebuild procedure is the harder of the two: its last scenario required the procedure to account for the shell's declared settings, and there are none now.

That scenario cannot be edited away. A MODIFIED delta replaces the whole requirement block, and `openspec validate --strict` refuses one that quietly drops a scenario the current spec still has — deliberately, since dropping a scenario at archive time is how an obligation disappears without anyone deciding it should. So the requirement is removed with a stated reason and re-added under a name that says what it now asks: which of the session's programs the checkout configures, and which run on their own defaults. The ordering obligation is carried over word for word; only the shell scenario is replaced.

**Delete the theme files rather than keep the palette.**

The colours were consistent and are not the reason for the revert, so keeping `.config/foot/themes/noctalia` and `.config/niri/noctalia.kdl` as plain untracked theme files was available. Doing so would leave two files named after a retired tool, included by two tracked configuration files, describing a palette nothing else on the machine still matches — the GTK, Qt, kitty and btop halves being gone. A colour scheme worth having is worth choosing and tracking deliberately; a stranded fragment of one is the kind of leftover `retired-tooling` exists to prevent. Everything removed is archived outside the repository first, so the palette is recoverable if it is ever wanted on purpose.

**Verify the compositor configuration by validation, not by restart.**

`niri validate` parses `config.kdl` and reports it valid, which is what catches the failure this repository has already hit once: niri refuses to load the entire configuration on a duplicate binding, so a bad edit costs the whole session rather than one key. Validation passes here.

It does not prove the session behaves, and the session has not been restarted — the shell is still running, the bar on screen is still its bar, and waybar has not started. That is left as an unchecked task rather than claimed, following the precedent set by `2026-09-05-seamless-window-appearance`, whose restart-dependent task is still open for the same reason.
