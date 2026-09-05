# Bare `niri` starts a full session via niri-session, so the environment is
# imported into systemd and graphical-session.target activates (foot-server
# and friends depend on it). Subcommands still go to the real binary:
#   niri msg ... / niri validate ... / niri --version
function niri --wraps niri --description 'Start a niri session, or pass through to the niri binary'
    if test (count $argv) -eq 0
        exec niri-session
    else
        command niri $argv
    end
end
