## 1. Spacing

- [x] 1.1 Set the compositor's window gaps to zero and verify the configuration validates
- [x] 1.2 Leave the focus ring at the compositor's default width and verify the border is off, so one focus indicator remains

## 2. Decorations

- [x] 2.1 Enable the compositor's request that clients omit client-side decorations, and verify the configuration validates
- [x] 2.2 State the terminal's preference for no decoration in its tracked configuration and verify `foot --check-config` accepts it

## 3. The restart dependency

- [x] 3.1 Establish why decorations persist after the change, by reading the client's log for a decoration-manager message and comparing the compositor and server start times against the configuration's modification time
- [x] 3.2 Record in the change's design that the compositor offers the decoration global only at startup, and that a server-backed client holds one connection for all its windows

## 4. Verification after restart

- [ ] 4.1 Restart the compositor and the terminal's server, then verify a newly opened terminal window carries no title bar and that the client's log no longer reports a missing decoration manager
