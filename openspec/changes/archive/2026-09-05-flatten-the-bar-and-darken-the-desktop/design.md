## Context

See proposal.md — Why. What shapes the approach is how waybar finds its two files, and what it does when it finds only one of them.

waybar resolves its configuration and its stylesheet independently. Each is searched for in `$XDG_CONFIG_HOME/waybar/`, then `~/.waybar/`, then `/etc/xdg/waybar/`, and the first hit wins for that file alone. So a user stylesheet with no user configuration is a supported arrangement: the appearance becomes ours and the module list stays the system's. The startup log states which of each it chose, which makes the arrangement checkable rather than assumed.

The stylesheet is not a cascade. waybar loads exactly one, so a user file does not layer over `/etc/xdg/waybar/style.css` — it replaces it. Anything the system file set that we do not restate is simply unset, including the font stack the Font Awesome glyphs need.

Configuration files do compose, through `include`. `man 5 waybar` states the precedence directly: "In case of duplicate options, the first defined value takes precedence, i.e. including file -> first included file". The including file wins, which is what makes a two-key override possible.

niri draws the surface behind windows itself. No wallpaper daemon is installed or running — `swaybg`, `swww` and `wbg` are all absent — so the desktop is a solid colour the compositor picks, and `layout { background-color }` is where that choice is stated.

## Goals / Non-Goals

**Goals:**

- A bar that reads as text over the desktop, with no surface of its own.
- Every state the module fills used to report still reported, by a different means.
- The appearance tracked without the module list becoming ours to maintain.
- A desktop colour that is a decision in a tracked file rather than a default.

**Non-Goals:**

- Choosing which modules the bar shows. The stock list is not obviously wrong, and changing it is a separate decision with its own reasons; this change is about how the bar looks, not what it says.
- Fixing the modules that render nothing. Five `sway/*` modules disable themselves under niri and `power-profiles-daemon` is not running. Both are visible in the startup log, both predate this change, and both are worth their own change rather than a silent fix inside a styling one.
- A wallpaper. Declaring a solid colour is not a step toward an image; if an image is ever wanted it arrives with a daemon and a tracked path, and it replaces this decision rather than extending it.
- Theming anything else from this palette. `retired-tooling` records what happened the last time a palette was applied by a mechanism instead of by hand.

## Decisions

**The appearance goes in a tracked stylesheet; the module list stays with the system.**

`.config/waybar/style.css` is ours and `/etc/xdg/waybar/config.jsonc` still supplies the modules. The alternative — copying the system configuration in so both files are ours — would take ownership of every module default for the sake of the two keys we actually want to change, and the copy would stop tracking the packaged file the moment a package update moved it.

Because the stylesheet replaces rather than cascades, it restates the font stack. Dropping it would not produce an obviously broken bar; it would produce one where the Font Awesome glyphs fall back to tofu, which is the kind of failure that reads as a font problem rather than as a missing line.

**Geometry gets a second tracked file, and that file includes rather than copies.**

Height is not settable from CSS — it is a property of the layer-shell surface, decided by the `height` key before any styling runs — so a stylesheet alone cannot make the bar shorter. `.config/waybar/config.jsonc` therefore exists, and contains an `include` of the system file plus `height` and `spacing`. It is nine lines of substance rather than the two hundred a fork would be, and a package update to the module list still reaches us.

`height` goes to 24 from the stock 30, against a 13-pixel font. That is enough for the text and its shadow and little else, which is the point: the bar's height is subtracted from every window on the output for the entire session.

Rejected: leaving `height` unset for waybar's dynamic sizing. It would size to content, which is tighter still, but the value would then be an emergent property of the font and the tallest module rather than a number anyone chose, and the spec's requirement about reserved height would have nothing to check.

**State moves to the text colour rather than being dropped.**

The stock fills are the only report of a critical battery, a disconnected network, a critical temperature, a muted output and a tray item wanting attention. Removing every fill without moving those signals would make the bar look calmer by making it silent about exactly the things it exists to say. Each becomes a text colour instead.

The idle inhibitor is the one to call out. It is the toggle that suppresses the 300-second `swayidle` lock declared in `config.kdl`, so "the screen will not lock itself" is a state with a security consequence, and it is now the only module that changes colour when it is *on* rather than when something is *wrong*.

**The palette is Catppuccin Mocha, reused rather than re-chosen.**

`.config/swaylock/config` already fixes these values, so red on the bar and red on the lock screen are the same red. The desktop takes `#181825`, one step from the lock screen's `#11111b`. No theme engine and no generated files: literal values in the two files that read them.

**Legibility is defended twice, because transparency moves it outside the bar.**

Once nothing is drawn behind the text, contrast becomes a property of the surface behind the bar. Both halves are cheap and neither is sufficient alone: a `text-shadow` on every label, which costs nothing over a dark surface and is what survives a light one, and a declared `background-color` in niri so the surface is a known quantity in the first place. The second is why the desktop colour is in this change rather than in one of its own — a transparent bar over an undeclared background is a half-made decision.

## Risks / Trade-offs

- **The system configuration changes under us.** → `include` is what we asked for, so a package update to the module list arrives without warning and could add a module the stylesheet does not name, which would then render with no padding and no state colours. The bar would still be legible and the fix would be one selector. Accepting this is the price of not owning the module list, and the alternative — a fork — trades a visible surprise for a silent staleness.
- **White text on a light wallpaper, if a wallpaper ever arrives.** → The shadow carries this only so far. A future image background would need the shadow revisited, and that is a reason for it to be a change rather than a drop-in.
- **The bar and the lock screen drift apart on colour.** → Two files hold the same literals with nothing enforcing agreement. Not mitigated; the comment in each names the other, which is the cheapest thing that makes the coupling visible to whoever edits one.
- **`niri validate` passes a colour that renders wrongly.** → Validation checks the syntax, not that the result is dark. The verification for that is looking at the screen.
- **Two modules keep rendering nothing.** → Stated as a non-goal above, and named in the proposal so the next reader does not mistake this change's arrival for their cause. The startup log names both.

## Migration Plan

Nothing migrates; the whole change is two new files, one added `background-color`, two `.gitignore` lines and README prose.

Reverting is deleting `.config/waybar/` and its allowlist entries, which returns the bar to `/etc/xdg/waybar/` in full, and deleting the `background-color` line, which returns the desktop to niri's default. Neither program writes state anywhere, so nothing outlives the revert.

One ordering note for a rebuild: the stylesheet is read at waybar's start and the geometry at the same moment, so a change to either needs waybar restarted rather than reloaded — `pkill -SIGUSR2 waybar` re-reads the stylesheet but the reserved height is fixed when the layer surface is created. niri, by contrast, applies `background-color` on save with no restart at all.
