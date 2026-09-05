## Context

See proposal.md — Why. The measured facts this design rests on, all taken on this machine: fish 4.6.0, foot 1.27.0, `TERM=foot`, and `wezterm` no longer installed. fish 4.6 carries `bind --preset -M insert ctrl-enter execute` in its preset table, which is only meaningful for a shell that can see Ctrl+Enter as a key of its own — it is the evidence that fish negotiates the kitty keyboard protocol and that `ctrl-enter` is a name this fish resolves.

The action itself is already correct and stays untouched: `functions/accept-autosuggestion-and-run.fish` accepts the suggestion and runs the line through tide's `_tide_enter_transient`, guarded for a machine without tide. Only the set of keys that reaches it is wrong.

The start-up ordering problem the existing code solves is unchanged and still load-bearing. tide binds `\r` and `\n` at file scope in `functions/fish_prompt.fish`, fish autoloads that file after `conf.d` and after `fish_user_key_bindings`, and `\n` is the same byte as `ctrl-j` — so `_accept_and_run_after_tide` forces the autoload from the first `fish_prompt` event and binds over tide, then erases itself. Anything added here has to be added in both places or it is subject to that same replacement.

## Goals / Non-Goals

**Goals:**

- Ctrl+Enter accepts and runs on foot, without giving up the behavior on a terminal that does not speak the kitty keyboard protocol.
- The comment block stops asserting something that measurement no longer supports.

**Non-Goals:**

- Deciding for the whole configuration which keys should move to protocol-only names. This change touches one action.
- Any `foot.ini` change. The protocol is negotiated at runtime between fish and the terminal; the terminal does not opt in through its configuration file.
- Making Ctrl+J stop performing the action. It is a real chord a user can press, and it has performed this action since the binding existed.

## Decisions

**Bind both names rather than replacing `ctrl-j` with `ctrl-enter`.** Replacing is the smaller diff and the wrong one. `ctrl-j` is not a workaround that foot made obsolete — it is two distinct things at once: the literal Ctrl+J chord, and the byte a terminal without the kitty keyboard protocol sends for Ctrl+Enter. Dropping it would break Ctrl+Enter on any such terminal and would silently retire Ctrl+J, neither of which this change is for. The `fish-key-bindings` delta states the general form: bind every encoding, so the terminal is not a precondition.

**Bind in both places, not one.** `fish_user_key_bindings` is where bindings are collected, and `_accept_and_run_after_tide` is where the ones tide replaces are put back. Only `\n`/`ctrl-j` collides with tide, so strictly `ctrl-enter` needs binding only in the first. Binding it in both anyway costs two lines and removes a standing trap: the two lists are read as a pair, and a reader who finds them different has to reconstruct which collision made them differ. The alternative — binding `ctrl-enter` once and leaving the handler to `ctrl-j` alone — is defensible and rejected for that reason, and the handler's comment already explains that its subject is the tide collision, so the extra line does not misrepresent why the handler exists.

**Rewrite the comment rather than amend it.** The current block reasons from a single measurement to a single key, and both its premise and its conclusion have moved. Appending a note would leave the WezTerm sentence standing as the primary explanation with a correction beneath it. The replacement states the two encodings, attributes each to a class of terminal rather than to whichever terminal the machine runs, and keeps the one thing that has not changed: Ctrl+J does the same thing as an unavoidable consequence of one byte serving two chords under the legacy encoding.

**Verify by inspecting resolved bindings, not by pressing the key.** `bind -M insert` at a real prompt reports what each name resolves to. The failure this fixes is precisely a key that resolves to a *preset* action rather than being unbound, so "the key does something" is not evidence — the check is that neither name reports `--preset`.

## Risks / Trade-offs

- **`ctrl-enter` is a name this fish knows, but the delivered key was not measured with `fish_key_reader` under foot.** → The preset entry proves fish has the name; it does not by itself prove foot delivers it. The task list measures the key under foot before the binding is written, so the change cannot be built on the same kind of inference that is being corrected.
- **A future tide version could bind `ctrl-enter` as it binds `\n` today.** → Then `ctrl-enter` needs the same treatment `ctrl-j` already has, and it is already in the handler that provides it. This is the concrete reason the second decision above resolves the way it does.
- **Two keys now run a command line where one did before.** → Both already ran it; the change is that both now accept the suggestion first. No key gains the ability to execute something it could not execute before.
