# Accept the autosuggestion fish is offering, then run the resulting command
# line. Bound to the accept-and-run key in conf.d/key-bindings.fish. Autoloaded,
# as mkcd is, so a session that never presses the key never defines it.
#
# The run is delegated to tide's _tide_enter_transient rather than done with a
# plain `commandline -f execute`, so that a command run from this key leaves the
# same collapsed prompt behind as one run with Enter -- which is what tide binds
# Enter to. Without that, scrollback would record which key ran which command:
# one full-height prompt among the collapsed ones, every time this key was used.
#
# Reproducing what that function does instead of calling it would mean copying
# tide's `commandline --is-valid`, paging-mode and repaint checks into this
# repository, frozen at the version they were copied from.
#
# The guard is what keeps this file correct where that function does not exist:
# on a machine without tide, or with tide_prompt_transient_enabled set to
# anything but true, since tide defines _tide_enter_transient only in that case.
# The key then still accepts and still runs, and only the prompt collapse is
# lost. An unguarded call would instead fail on every press.
function accept-autosuggestion-and-run --description 'Accept the autosuggestion and run the command line'
    commandline -f accept-autosuggestion

    if functions -q _tide_enter_transient
        _tide_enter_transient
    else
        commandline -f execute
    end
end
