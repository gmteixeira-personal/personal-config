## 1. Declare the arrangement

- [x] 1.1 Add an `ultrawide` profile to `~/.config/kanshi/config` between `docked` and `mobile`, matching the LG by make/model/serial with `mode 3440x1440@159.962` at `position 0,0` and `eDP-1` at `scale 1.25 position 952,1440`; verify with `kanshi -h` style parse acceptance, i.e. `pkill -HUP kanshi` returns and the session does not lose its outputs
- [x] 1.2 Record the geometry derivation in a comment above the profile — the ASCII x-axis diagram, `1920 / 1.25 = 1536`, `(3440 - 1536) / 2 = 952`, why scale 1 on the ultrawide, and why the mode is pinned; verify the comment names the dependency of the position on the scale, as `docked`'s comment does

## 2. Apply and confirm the live geometry

- [x] 2.1 Send `pkill -HUP kanshi` and verify `niri msg outputs` reports `DP-3` at logical position `0, 0` size `3440x1440` scale 1 with current mode `3440x1440 @ 159.962 Hz`, and `eDP-1` at logical position `952, 1440` size `1536x960` scale 1.25
- [x] 2.2 Verify the pointer crosses downwards from the ultrawide into the laptop within the laptop's span (x 952..2488) and stays on the ultrawide outside it -- confirmed from the logical geometry niri reports, the overlap being exactly x 952..2488 on the y 1440 boundary
- [x] 2.3 Verify the bar is present and correctly placed on both screens without a reload, confirming it has no per-output targeting to update

## 3. Keep the compositor note truthful

- [x] 3.1 In `~/.config/niri/config.kdl`, replace the undeclared-set example "the laptop plus a single external, say" — one such set is now declared — with an example that is still undeclared, such as all four screens at once; verify the file still parses with `niri validate`

## 4. Regression check on the existing arrangements

- [x] 4.1 Verify the `docked` and `mobile` profiles are byte-identical to before this change (`git diff ~/.config/kanshi/config` shows only the added profile and its comment)
