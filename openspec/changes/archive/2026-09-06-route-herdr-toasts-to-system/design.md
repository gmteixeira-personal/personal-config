## Context

See proposal.md — Why. The constraints that shape the approach, all established before this design:

- herdr's `[ui.toast] delivery` accepts exactly four values: `herdr` (a toast drawn inside the herdr window), `terminal` (an escape sequence to the outer terminal, which also survives SSH), `system` (the local OS notification service), `off`.
- herdr's configuration has no conditionals. There is no include directive, no `config.local.toml`, no per-host or per-platform section. The only override is `HERDR_CONFIG_PATH`, which replaces the entire file.
- This machine runs niri, which spawns `footclient` (`.config/niri/config.kdl:422`), and mako, which owns `org.freedesktop.Notifications` per `desktop-notifications`. `libnotify-0.8.8` and `/usr/bin/notify-send` are installed.
- The other machine this repository is restored onto runs under WSL, where nothing owns the notification bus name.

## Goals / Non-Goals

**Goals:**

- One value in one tracked file, correct on both machines, with the difference between them absorbed off the tracked configuration.
- Keep the setting's comment true after the change — it is currently the only part of this that is actually wrong rather than merely suboptimal.

**Non-Goals:**

- Changing which agent states herdr notifies about, or the notification sound. Only the delivery path moves.
- Making the WSL machine work as part of this change. The requirement that such a machine supply `notify-send` is stated here, but installing it is a step on that machine, and this repository cannot assert it.
- Per-application notification rules in mako. What arrives is shaped by `desktop-notifications`, not here.

## Decisions

### Deliver through `system`, and let the machine answer for what that means

`system` names an intent — the machine's notification service — where the other three name a mechanism. That is what makes a single value survivable across machines with no branch: the configuration stops describing how the notification is drawn and starts describing who is responsible for drawing it, and each machine answers with what it has.

It also puts herdr's notifications under the rules the session already fixes for every other notification. `desktop-notifications` requires the session palette, criticals that wait to be dismissed, and ordinary notifications that expire on a timer. An in-app toast is outside all of that by construction.

**Alternative — `terminal`, letting the outer terminal route it.** This also gives one value on both machines, and on paper it is better: foot's default notification command is

```
notify-send --wait --app-name ${app-id} --icon ${app-id} --category ${category} --urgency ${urgency} --expire-time ${expire-time}
```

so mako would receive a real app-name and could be given per-application rules, which `system` does not allow — herdr sends through `notify-send` with no `--app-name`, so its notifications are not matchable in mako except by their text. Under WSL the outer terminal is Windows Terminal, which handles OSC 9 and would raise a native toast with nothing installed.

Rejected on a detail that defeats the purpose: foot's `desktop-notifications.inhibit-when-focused` defaults to `yes`. The case this change exists to serve — an agent needing attention in a pane of the herdr window you are looking at, or in another workspace of the same herdr session — is a case where the foot window frequently *does* have keyboard focus, and foot drops the notification. Recovering it means setting `inhibit-when-focused=no`, which lifts inhibition for every notification foot raises, not herdr's alone, and the app-name that was the attraction is `footclient` — shared with every other notification from every other pane. The benefit is real but it is bought by changing terminal-wide behaviour to fix an application-level problem, and by making a second tracked file (`.config/foot/foot.ini`) part of herdr's notification path.

**Alternative — two configuration files selected by `HERDR_CONFIG_PATH`.** Rejected on cost. Two copies of a hundred-line file differing in one word, and every later change to any other setting in it paid twice, with no mechanism to detect that they drifted.

### Put the platform difference on the WSL machine's `PATH`

The tracked configuration asks for a notification service. Where the system has none, the machine supplies the command — `wsl-notify-send`, or a script calling `powershell.exe` — installed on that machine and named `notify-send`.

This is the same shape as the capability checks already in these dotfiles: `.bashrc` asks whether `direnv` is present rather than which system it is on, and the Neovim configuration installs a clipboard bridge only where Neovim reported no provider, asking the provider rather than testing for WSL. Both put the question at the capability, not the platform, and both leave the tracked file identical everywhere.

### Rewrite the comment rather than adjust it

The existing comment explains `terminal` and `herdr` and gives WSL as its reason. After this change it would describe two values the setting does not hold, on a machine that is not the one named. The spec requires the comment to state what the value does and why an in-app toast was not kept; that is a replacement, not an edit.

## Risks / Trade-offs

- **A machine with no service and no shim gets silence, which is worse than an in-app toast there.** → Stated as an accepted risk in the proposal and covered by the spec requirement that such a machine supply the command. Silence is the failure `desktop-notifications` already describes: the sending program's error goes to a stream nobody reads, and on screen nothing distinguishes a discarded notification from one never sent. The mitigation is a step on the WSL machine, performed when that machine is next used, and its absence degrades herdr's notifications there without affecting anything else.
- **herdr's notifications are not matchable in mako.** → Accepted. They arrive through `notify-send` with no `--app-name`, so a mako rule can only match their summary or body text. No per-application rule is wanted today; if one becomes wanted, the `terminal` alternative above is the path back, with its own costs re-examined then.
- **The change is invisible until an agent state changes.** → `herdr notification` over the socket API raises one on demand, which is the verification step rather than waiting for an agent to block.
- **Reload semantics for this particular setting are assumed, not known.** → `herdr server reload-config` is documented to reload `config.toml` and every other setting in this file has behaved that way. If delivery turns out to be read only at server start, the fallback is a restart, which costs nothing here — the spec's reload scenario is what would fail, and it would be corrected rather than the approach.

## Migration Plan

1. Rewrite the comment and keep `delivery = "system"` in `.config/herdr/config.toml`. The value is already in the working tree.
2. `herdr config check` — the configuration must validate before it is reloaded.
3. `herdr server reload-config` on the running server; open sessions survive.
4. Raise a notification through `herdr notification` and confirm mako displays it in the session palette.
5. On the WSL machine, when next used: install a `notify-send` on `PATH` and confirm a notification reaches a Windows toast. Not part of this repository's change.

Rollback is the reverse of step 1 — `delivery = "herdr"` and a reload. No state is migrated and nothing outside the one file is touched, so there is nothing else to undo.
