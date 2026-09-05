## 1. Confirm what is being recorded

- [x] 1.1 Read `/etc/greetd/config.toml` and verify its default session command is `tuigreet --time --remember --remember-user-session --asterisks --cmd niri-session`, so the content the README will carry is copied rather than recalled
- [x] 1.2 Verify `systemctl is-enabled greetd` reports `enabled` and `systemctl get-default` reports `graphical.target`, so the enablement the README claims is the machine's actual state
- [x] 1.3 Verify `/usr/share/wayland-sessions/niri.desktop` has `Exec=niri-session`, and that it is the only entry in that directory, so the remembered-session caveat is stated at the right strength
- [x] 1.4 Verify the running session reaches the end state — `systemctl --user is-active graphical-session.target` is `active`, the user manager carries `WAYLAND_DISPLAY`, and both foot server units are active — so the documentation records a verified path rather than an intended one

## 2. Name the login software

- [x] 2.1 Add a **Required** entry for `greetd` stating that without it the machine boots to a text console and the session must be started by hand, and verify it identifies that as a degradation with a working fallback rather than a broken session
- [x] 2.2 Add a **Required** entry for `tuigreet` stating that without it greetd starts and has nothing to present, and verify it says this failure looks like a broken boot rather than a missing package

## 3. Record how the session is entered

- [x] 3.1 Add a final step to **Rebuilding the desktop session** carrying `/etc/greetd/config.toml` verbatim, and verify the reproduced block matches the file on this machine by diffing the two
- [x] 3.2 In the same step, name `systemctl enable greetd` and the `graphical.target` default, and verify the step warns that enabling greetd on a machine already running another display manager is a conflict to resolve first
- [x] 3.3 State in that step that all three routes into the session — the greeter's `--cmd`, the session entry its picker lists, and typing `niri` at a prompt — run `niri-session`, and verify each of the three is named with the file that decides it
- [x] 3.4 Note the `--remember-user-session` caveat: a remembered choice takes precedence over `--cmd`, and is harmless only while `/usr/share/wayland-sessions/` holds one entry; verify the note says what makes it become live
- [x] 3.5 Verify the new step is last in the procedure and that steps 1 through 3 still read as a complete route to a working session without it

## 4. Record what the repository cannot carry

- [x] 4.1 Add a row to **What is deliberately not tracked** for `/etc/greetd/config.toml`, and verify the reason given is that it lies outside the repository root rather than that it was excluded by choice

## 5. Validate

- [x] 5.1 Run `openspec validate declare-the-login-manager --strict` and verify it passes
- [x] 5.2 Verify this change declares no delta against `desktop-session-declaration`, so it cannot collide with the open `dark-lock-screen-on-idle` change over the same requirement block
- [x] 5.3 Verify no tracked configuration file was modified by this change — `git diff --stat` should show `README.md` and the change's own artifacts, and nothing under `.config/`
