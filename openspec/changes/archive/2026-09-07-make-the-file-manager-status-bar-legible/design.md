## Context

See proposal.md — Why.

`~/.config/yazi/` holds `flavors/` and `package.toml` and nothing else: the file manager has never had a theme file, so every colour in it comes from the program's shipped `theme-dark.toml`. That file names palette slots — `normal_main = { bg = "blue", bold = true }`, `normal_alt = { fg = "blue", bg = "gray" }`, `progress_label = { bold = true }` — and states no foreground on two of the three.

`.config/foot/foot.ini` sets `foreground=aaaaaa` and, in a comment of its own, declines to restate the sixteen palette slots: "reachable only by a program choosing its own colours". That is accurate, and this is the program. Slot 4 is foot's `#24acd4` and slot 7 its `#e6e6e6`, which is what the two badges and the two chips are painted with.

Measured from a screenshot of the running program: badges `#aaaaaa` on `#24acd4` at 1.14:1, chips `#24acd4` on `#e6e6e6` at 2.12:1, the row under the cursor `#11111b` on `#24acd4` at 7.08:1.

A Catppuccin Mocha flavor is installed under `flavors/` but nothing selects it, so it draws nothing today.

## Goals / Non-Goals

**Goals:**
- Give the two unreadable elements a stated foreground, and the two pale chips a background from the session's palette.
- Leave the file with the measurements in it, so the next reader can tell a value that was checked from a value that was typed.

**Non-Goals:**
- Adopting the installed flavor. It is a separate decision about every surface the program draws, and its own status-bar values do not clear the threshold either — its `progress_label` is `#ffffff` on `#89b4fa`, 2.11:1.
- Tracking `flavors/` or `package.toml`. Nothing this change writes references them, so tracking them would vendor a third-party tree the configuration does not use.
- Touching `.config/foot/foot.ini`. Measured, repainting the slots does not fix the fault.
- The select and unset mode badges. They carry the same missing foreground and are equally unreadable the moment they appear, but they are a different keystroke away and were not what was reported.

## Decisions

**Write a `theme.toml` with overrides rather than selecting the installed flavor.**
The flavor would fix the mode badge — it states `fg = "#1e1e2e"` where the shipped theme states nothing — and would leave the position badge at 2.11:1, still short. It would also repaint every other surface in the program at the same time, which is a much larger change than the one asked for and one nobody has looked at. Overriding three keys changes three things.

**White on the badges, not a dark foreground, even though dark measures better.**
`#ffffff` on that blue is 2.65:1; `#11111b` on the same blue is 7.08:1. Dark is the better number and white is what was asked for after seeing both described. The requirement's answer to this is to record the ratio rather than to overrule the choice: 2.65:1 is more than double what it replaces, the badge is three glyphs of bold text rather than a paragraph, and the value is one line to change if it reads thin in use.

**Catppuccin Mocha's `surface0` behind the chips.**
The chips need a dark background so the blue text on them stops fighting a near-white slot. `#313244` takes them to 4.75:1, over the threshold, and it is an entry of the palette this session already restates in five files rather than a grey mixed by hand. `surface1` at `#45475a` was the alternative and lands at 3.44:1, under.

**Keep `bg = "blue"` on the mode badge as a slot name.**
Every other value this file writes is a literal, and this one is not, which needs saying rather than hiding. The blue is the colour already on screen and the change is not about it; naming a literal would mean picking one, which is a decision nobody made. The requirement allows a retained colour to stay named by slot provided the file says that is what it is.

**Leave the row under the cursor alone.**
Not reachable: the program has no theme key for it and highlights by reversing the row's own colours, so the only lever is the file-type colour every directory row is drawn in. It is also already at 7.08:1, so the change most obviously suggested by the surrounding work — make it match the badges — would take the best element in the window down to the worst.

## Risks / Trade-offs

- **The badges land at 2.65:1, still under 4.5:1** → Recorded in the file next to the value, so it reads as a known position rather than a passed check. The dark alternative is one line away and the file names it.
- **Two of the three overridden keys are shared with modes nobody has looked at yet** → `normal_main` and `normal_alt` are the normal mode's; select and unset have their own keys and keep the shipped values, so pressing `v` still shows the original fault. Left deliberately, and named here so it is found rather than rediscovered.
- **A future flavor selection would override all of this** → A `[flavor]` line and per-key overrides in the same file is a resolvable but confusing combination. If the flavor is ever adopted, this file is where the conflict surfaces, and the measurements in it are the record of what the flavor has to beat.
- **The measurements were taken from a screenshot rather than from the running program's own output** → Pixel values sampled from a capture of the real window, which is the only way to see what the two configurations produce together; nothing else reports the composite.

## Migration Plan

Write the file, allow it through `.gitignore`, and restart the file manager — it reads its theme at startup, so a running instance keeps the old colours. Rollback is deleting the file, which returns every value to the shipped theme.
