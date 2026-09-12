## Context

Output geometry lives in `~/.config/kanshi/config` as one profile per connected set; see proposal.md - Why for the motivation and `openspec/specs/output-layout/spec.md` for the requirements this arrangement has to satisfy. kanshi picks the first profile whose output list matches the connected set *exactly*, so a new arrangement is additive: it cannot alter when `docked` or `mobile` fire.

The two screens involved:

| | connector | native mode | physical width | scale | logical size |
|---|---|---|---|---|---|
| LG ultrawide | `DP-3` | 3440x1440@159.962 | 800 mm | 1 | 3440x1440 |
| laptop panel | `eDP-1` | 1920x1200@60.003 | 300 mm | 1.25 | 1536x960 |

## Goals / Non-Goals

**Goals:**

- One profile matching the ultrawide-plus-laptop set, geometrically correct and stated with the arithmetic that produced it.
- The ultrawide at its full refresh rate without depending on mode enumeration order.

**Non-Goals:**

- A profile for the ultrawide together with the two MSI externals. That is a four-screen set the user has not worked in; the spec already leaves an undeclared set to the compositor, and declaring a guessed arrangement would be indistinguishable from a considered one once applied.
- Any change to `docked` or `mobile`, or to how kanshi is started.
- Moving geometry back into the compositor configuration.

## Decisions

**The laptop stays at 1.25, not the 1.5 used docked.** The enlargement in `docked` was justified by the laptop sitting both lower and further away than screens across the desk. The ultrawide stands directly above the laptop, so the user's distance to the panel is the same as when the laptop is alone, and 1.25 is what that distance wants. The alternative — reusing 1.5 for consistency with the other docked profile — makes the panel's content larger than the screen above it for no reason, and encodes "docked" as the thing scale depends on, which the spec now explicitly rejects.

**Scale 1 on the ultrawide.** 3440 px across 800 mm is ~109 DPI, close enough to the density the unscaled toolkit sizes assume; scaling it would cost logical width on a screen whose width is its whole point. Rejected 1.25 for that reason.

**Centring offset is derived, not tuned.** With the laptop at 1.25 its logical width is 1920 / 1.25 = 1536, so `(3440 - 1536) / 2 = 952`. Writing 952 without the derivation is what makes a later scale change silently decentre the panel, so the profile records both the arithmetic and the dependency, the same way `docked` does. 1.25 also divides 1920 without remainder, satisfying the spec's no-fractional-width rule.

**Vertical stacking, ultrawide at the origin.** The ultrawide occupies y 0..1440 and the laptop y 1440..2240. Putting the ultrawide at `0,0` rather than the laptop keeps the coordinate space non-negative and mirrors `docked`, where the top row is the origin row.

**Mode pinned by value.** The panel reports both 3440x1440@159.962 and 3440x1440@99.997 as preferred, so the profile states `mode 3440x1440@159.962`. Alternative considered: leaving the mode out and relying on the compositor's preference among preferences — rejected because it is enumeration order, and it fails silently at 100 Hz on a 160 Hz panel.

**Match the ultrawide by make/model/serial, not `DP-3`.** Consistent with the existing externals. There is only one ultrawide, so a connector match would work today, but it breaks the moment the cable moves to another port — and on this machine the port the dock presents is not stable.

## Risks / Trade-offs

- **All four screens connected at once falls through to automatic placement** → Accepted and documented: the spec requires an undeclared set to be left to the compositor, and no error is reported. If that set becomes routine, it gets its own profile.
- **The pinned mode becomes invalid if the ultrawide is replaced by a different panel with the same make/model/serial match string** → Not possible; the serial is in the match. A replacement panel simply does not match, and the set falls through to automatic placement rather than failing to apply a mode.
- **A future change to the laptop's 1.25 decentres it** → Mitigated by recording the derivation in the profile and by the spec requirement that scale and position move together. Not eliminated: nothing enforces it mechanically.

## Migration Plan

Add the profile and send kanshi `SIGHUP`; it re-reads its configuration and re-applies the matching profile against the live set, so the arrangement takes effect without restarting the session. Rollback is deleting the profile and sending `SIGHUP` again — the set then falls through to automatic placement, which is the behaviour before this change.
