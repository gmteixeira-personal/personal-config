## Context

See proposal.md — Why. The constraints that shape the approach:

- `.config/herdr/` holds `config.toml` beside `herdr.sock`, `herdr-client.sock`, three log files, `session.json` and `.plugins.lock`. The sockets are not regular files, and the logs and session record describe one machine's activity.
- Block 3 of the ignore file can name a single file at any depth, and the repository already does this for `.config/gh/config.yml` and `.config/caveman/config.json` — in both cases the directory holds a credential or state file that must stay out.
- herdr reloads its configuration on request into the running server, so a prefix change does not require restarting it or losing a session.
- The tool's documented key list has no send-prefix binding, so whichever key is chosen is consumed by herdr rather than forwarded to the program in the pane.

## Goals / Non-Goals

**Goals:**

- The prefix, and any later herdr preference, survives a move to a new machine.
- Nothing from that directory reaches a public remote except the file that was reviewed for it.

**Non-Goals:**

- Pinning the theme, status indicators or toast delivery in the spec. They live in the same file and now travel with it, but they are preferences that will change; a spec that enumerated their current values would be edited every time one did.
- Tracking `.config/herdr/` as a directory.
- Reproducing herdr's full key map. The prefix is what was lost and what this fixes; the actions hanging off it are the tool's defaults.

## Decisions

**Allowlist the file, not the directory.** `!/.config/herdr/config.toml` names exactly what was reviewed. A directory entry would re-include the sockets and logs as well, and it would keep doing so for whatever herdr adds to that directory in a later version — a file nobody has looked at, tracked by a rule written before it existed. This mirrors `.config/gh/`, whose `config.yml` is tracked while `hosts.yml` holds the OAuth token.

**Declare the prefix in the tracked file rather than accepting the default.** The failure this change fixes was silent: the tool worked, and only the binding was wrong. Writing the value down — even where it is the value someone would set again by hand — is what makes the next restoration verifiable rather than remembered.

**Reload rather than restart.** herdr applies a configuration reload to the running server, which is how the change was made to take effect without disturbing the session it was made from. Alternative considered: restarting the server. Rejected — it ends every pane to change one binding.

**Keep the spec's requirements about tracking and state separate.** One says what must be present, the other what must be absent. Combining them would produce a requirement whose scenarios pull in opposite directions, and the absent half is the one that matters if herdr later writes something new into that directory.

## Risks / Trade-offs

- **The prefix is not delivered to programs in the pane** → `ctrl+f` is consumed by herdr, so a program that wanted it does not see it. Inherent to prefix keys and true of the `ctrl+b` default equally; the choice of which key to lose is the user's.
- **herdr may add a new file to that directory** → it stays ignored by default, which is the safe direction. The cost is that a genuinely useful new configuration file needs its own allowlist entry.
- **The tracked file is publicly readable** → its content is preferences: a theme name, indicator style, toast delivery, and a key binding. It carries no host, token or path.
- **Rollback** → remove the allowlist line and untrack the file; herdr keeps working from whatever is on disk.
