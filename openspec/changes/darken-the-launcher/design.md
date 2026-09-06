## Context

See proposal.md — Why.

The constraint that shapes everything below is that fuzzel's colours are a flat list of eleven keys in one `[colors]` section, with no notion of a palette, a variable or a reference. `/etc/xdg/fuzzel/fuzzel.ini` ships them commented out at Solarized Light values, and an uncommented key in `~/.config/fuzzel/fuzzel.ini` replaces the built-in default for that key alone. There is no inheritance to lean on and nothing to import, so the whole question is which of the session's existing values goes on which of the eleven keys, and how a reader later checks that answer.

The session's palette is Catppuccin Mocha. This repository does not vendor it; it restates the values it needs in each file that needs them, and each of those files says so in a comment. `.config/waybar/style.css` names `.config/swaylock/config` as where the palette already lives, and `.config/swaylock/config` carries the fullest set of values — base, surface0, text, and the accents blue, green, yellow, peach, red and maroon. Those two files are the reference for both the values and the convention.

fuzzel 1.14.0 is what is installed, and its `[colors]` section defines eleven keys: `background`, `text`, `prompt`, `placeholder`, `input`, `match`, `selection`, `selection-text`, `selection-match`, `counter` and `border`.

## Goals / Non-Goals

**Goals:**

- Assign all eleven colour keys, so no state can arrive Solarized later.
- Reuse the assignments the session has already made — the value that means "resting text" on the lock screen means resting text in the launcher, and the value that means "the thing you are looking at" on the bar means that in the launcher too.
- Leave the file readable as a decision rather than as a block of hex.

**Non-Goals:**

- Any geometry: `width`, `lines`, `horizontal-pad`, `vertical-pad`, `anchor` and the `[border]` section's `width` and `radius` stay at their defaults. The complaint is that the launcher is white, not that it is the wrong shape, and moving both at once makes neither reviewable.
- Fonts and icons. `font` and `icon-theme` are untouched.
- Extracting a shared palette. Four files in four formats cannot share one, and inventing a generator to write them would be a larger and more fragile thing than the four comments that do the job today.
- Transparency. Discussed under Decisions and rejected.

## Decisions

### The palette is Catppuccin Mocha, taken from `.config/swaylock/config`

The alternative was to sample the values already on screen — niri's `background-color "#181825"` and waybar's white text — and build outward from those. Rejected because both of those files took their values from Mocha in the first place, and re-deriving from two of the palette's members loses the rest of it. Going to the palette directly, through the file this repository already treats as its statement of it, is what makes the fourth file agree with the other three rather than merely look similar.

### Which value goes on which key

The mapping is not free choice; each value is already doing a job somewhere in the session, and the launcher's keys are matched to the jobs rather than to what looks good in isolation.

| fuzzel key | Value | Mocha name | Why this one |
| --- | --- | --- | --- |
| `background` | `1e1e2eff` | base | swaylock's `inside-color`. One step lighter than the desktop's `#181825` (mantle), so the launcher reads as a surface over the desktop rather than a hole in it. |
| `text` | `cdd6f4ff` | text | swaylock's `text-color`. The session's resting foreground. |
| `input` | `cdd6f4ff` | text | What is typed is foreground, not chrome. Same value as `text` by intent, not by omission. |
| `prompt` | `6c7086ff` | overlay0 | The bar's grey for "present but not the point" — a muted output, an empty workspace. The prompt is furniture. |
| `placeholder` | `6c7086ff` | overlay0 | Same reason. It is a hint, and it must not be mistaken for typed input. |
| `counter` | `6c7086ff` | overlay0 | Same reason. A match count is a reading about the list, not an item in it. |
| `selection` | `313244ff` | surface0 | swaylock's `ring-color`, its one step above `inside-color`. The selected row lifts off the background by the same increment the lock screen's ring does. |
| `selection-text` | `cdd6f4ff` | text | The selected row's text does not change meaning, so it does not change colour. The fill carries the selection. |
| `match` | `89b4faff` | blue | The bar's focused workspace and swaylock's "verifying" are both this blue: it is the session's "this is the part that matters". The matched substring is exactly that. |
| `selection-match` | `89b4faff` | blue | The match keeps its meaning inside the selection. Contrast against `#313244` is sufficient. |
| `border` | `313244ff` | surface0 | Same value as `selection`, so the launcher's outline is the palette's structural step rather than an accent. |

The border is the one place where a reasonable alternative was rejected on taste rather than on precedent. Catppuccin's own published fuzzel port uses lavender `#b4befe` for the border, which would make the launcher's outline the loudest thing on the screen. The session's established habit is the opposite — the bar draws no surface at all, windows have no borders, and colour is spent only on state. Surface0 keeps the border as an edge rather than a highlight, and leaves blue meaning one thing.

### Every key is set, including the ones that look right by default

Setting only `background`, `text` and `selection` would fix the flash of white and leave `placeholder`, `counter`, `prompt` and `border` on Solarized. Those four are not visible at rest, which is exactly the problem: they surface later, one state at a time, and each looks like a fresh bug. The eleven keys are enumerated in `/etc/xdg/fuzzel/fuzzel.ini`, so completeness here is checkable rather than aspirational.

### Opaque background, no transparency

fuzzel's alpha channel is the last byte of each value and the packaged default is opaque. A semi-transparent launcher over the wallpaper was considered and rejected: `waybar/style.css` already records that text over an unknown wallpaper cannot rely on contrast it does not control, and it pays for its own transparency with a text shadow. fuzzel has no equivalent setting, so transparency there would be a legibility problem with no available mitigation. All eleven values end in `ff`.

### The provenance comment names `.config/swaylock/config`

`.config/waybar/style.css` already names that file as the palette's home, so a second file naming it makes the convention a pattern rather than a one-off, and points a reader at the file with the fullest set of values. The alternative — writing "Catppuccin Mocha" alone — names the palette but not this repository's copy of it, which is the half that lets a value be checked without a web search.

## Risks / Trade-offs

- **The palette is restated a fourth time, so it can drift a fourth way.** → Accepted, and mitigated only by the comments. No mechanism can fix this without a generator writing four formats, which is more machinery than four files justify. The spec's second requirement is what keeps the comments from being dropped as noise.
- **A fuzzel update adds a colour key, and it arrives Solarized.** → Not preventable from here; fuzzel has no "theme everything" switch. The mitigation is that the new key would be commented into `/etc/xdg/fuzzel/fuzzel.ini` by the package, where the existing eleven are, so the check is a diff of that file rather than a hunt.
- **Blue on surface0 for `selection-match`.** → `#89b4fa` on `#313244` is a light accent on a dark fill and well clear of the contrast floor. The riskier pairing would have been match-blue against a light selection, which does not arise because the selection is dark.
- **The values are correct but the reason they were chosen lives only here.** → The mapping table above is the record. The configuration file carries the palette's name and its source, not the eleven justifications, because a comment per key would be longer than the section it annotates.

## Migration Plan

There is no migration. fuzzel reads its configuration when it starts and it starts once per invocation, so the next `Mod+D` after the file is written shows the new colours; nothing needs reloading, restarting or signalling. Rollback is deleting the `[colors]` section, which returns the file to its current one-line state and the launcher to the packaged defaults.
