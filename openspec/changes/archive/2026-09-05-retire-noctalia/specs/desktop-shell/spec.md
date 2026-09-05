## REMOVED Requirements

### Requirement: One shell provides the session's furniture

**Reason**: The session no longer has a single desktop shell. noctalia is retired, and the bar, launcher and lock screen return to the three separate programs that provided them before it — waybar started by the compositor, fuzzel on `Mod+D`, swaylock on `Super+Alt+L`.

**Migration**: Covered by `graphical-session-startup`, which already governs what the compositor starts, and by the required-software requirement in `desktop-session-declaration`, which names each program and what is lost without it. Nothing needs installing: all three were kept installed by this capability's own "The replaced components remain installed" requirement.

### Requirement: Bindings address the running shell over its IPC socket

**Reason**: There is no running shell to address. The launcher and lock bindings spawn fuzzel and swaylock directly, which is what they did before this capability existed and is the only thing those programs support.

**Migration**: `Mod+D` and `Super+Alt+L` behave as they did before noctalia: each starts its program, paying that program's startup cost per press. The clipboard binding is removed entirely rather than remapped.

### Requirement: Clipboard history outlives the window that copied

**Reason**: Nothing in the session provides clipboard history any more, and this change does not replace it. The requirement is removed rather than left unmet, because a requirement no part of the configuration attempts to satisfy is a false record of what the session does.

**Migration**: None. This is a real loss, stated as one: a Wayland selection is again owned by the client that set it, so text copied in a window and then closed before pasting is gone. `cliphist` remains installed and unwired. Restoring history is a new change, proposed on its own merits, needing a watcher entry, a binding and a picker.

### Requirement: A new binding is validated against the compositor's own

**Reason**: The binding this requirement was written for — `Mod+Alt+V` for the clipboard panel, moved there because `Mod+V` is niri's `toggle-window-floating` — is removed with the shell, so there is no shell binding left to validate.

**Migration**: The underlying practice is unchanged and unaffected by this capability's removal: niri refuses to load the whole configuration on a duplicate binding, so `niri validate` is run after any binding edit. It was run for this change and reports the configuration valid.

### Requirement: The replaced components remain installed

**Reason**: Discharged. This requirement existed so the shell could be abandoned by restoring three lines, with nothing to reinstall, and that is exactly what happened — waybar, fuzzel and swaylock were all present and unconfigured when the revert was made. It has no work left to do once they are the session's live components again.

**Migration**: The three programs move from this requirement's protection into the required-software documentation as ordinary session dependencies, where their absence costs the bar and two keys rather than a fallback.

### Requirement: No unused clipboard backend is carried

**Reason**: The requirement was conditional on the shell providing clipboard history natively, which made a separate daemon redundant and worth recording as unused. With no shell, the condition does not hold.

**Migration**: `cliphist` stays installed and stays unwired, so the observable state is unchanged. It is now unused because nothing in the session provides clipboard history at all, rather than because something else already did.
