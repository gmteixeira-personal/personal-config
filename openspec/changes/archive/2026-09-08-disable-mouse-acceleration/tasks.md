## 1. Compositor configuration

- [x] 1.1 Uncomment `accel-profile "flat"` in the `mouse` block of `.config/niri/config.kdl`, leaving `accel-speed` commented out, and verify `niri validate` reports the config as valid
- [x] 1.2 Replace the niri-shipped example comments in that block with a comment recording why the mouse takes a constant ratio, why `accel-speed` is deliberately left unset under the flat profile, and why the mouse's hardware resolution is not the layer used — verify by reading the block back and checking all three are accounted for
- [x] 1.3 Add a comment to the `touchpad` block recording that it keeps the adaptive profile on purpose, so the two blocks do not read as an oversight — verify by reading it back and checking it names the reason the mouse's argument does not carry across

## 2. Verification

- [x] 2.1 Save the config without restarting the session and verify niri adopts the change on the running session, with no logout and no reconnection of the mouse
- [ ] 2.2 Move the mouse across a fixed physical distance slowly and then quickly, and verify the cursor travels the same distance on screen both times
- [ ] 2.3 Cross a fixed distance on the touchpad slowly and then quickly, and verify the cursor still travels further on the fast movement
- [ ] 2.4 Verify that scrolling, the mouse buttons, and the touchpad's tap-to-click and natural scrolling all behave as they did before
