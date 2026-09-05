## 1. Declaration

- [x] 1.1 Export the desktop shell's effective configuration to `.config/noctalia/settings.toml` and verify `noctalia config validate` accepts it
- [x] 1.2 Verify the export contains no absolute path naming the home directory and no token, key or account identifier
- [x] 1.3 Add an allowlist entry for the declaration and verify `git check-ignore -v` reports that rule rather than the deny-by-default `*`

## 2. Required software

- [x] 2.1 Add the compositor, terminal and desktop shell to the README's **Required** group, each stating what breaks in its absence and where it comes from, and verify each tracked configuration file has a corresponding named program
- [x] 2.2 Add the X11 compatibility helper to **Required**, stating that X11 clients do not run without it
- [x] 2.3 Add the superseded bar, launcher and lock screen to **Optional**, stating what is lost rather than implying they are unimportant

## 3. Rebuild procedure

- [x] 3.1 Document rebuilding the session in the README in an order that works — software first, then the tracked configuration, then how the session is started — and verify it names the session-start command that activates the graphical-session user units
- [x] 3.2 Document that the machine-local state layer overrides the declaration, and name the command that regenerates the declaration, verifying the stated precedence matches observed behavior

## 4. Verification

- [x] 4.1 Verify the declaration would apply on a machine without a state directory, by confirming a key present only in the config layer takes effect
- [x] 4.2 Verify the state directory is still untracked and the ignore policy's `.local/` denylist is unchanged
