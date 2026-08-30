# Environment for every fish shell, interactive or not. Mirrors the block above
# the interactivity guard in ~/.bashrc, which sits there so that scripts and
# tool runners see these too; conf.d gives fish the same reach with no guard.
#
# bash keeps its own copy rather than deferring to this file. ssh sessions,
# sudo -s, and anything running $SHELL still land in bash, and those need the
# exports as much as fish does.

# Per-machine tool installs, listed in the order they should end up in PATH.
# fish_add_path ignores a directory that does not exist and never adds a second
# copy of one already there -- the two checks prepend_path in ~/.bashrc
# hand-rolls. -g keeps the change global rather than universal, so it lives in
# this file and not in fish_variables, where it would outlive an edit here.
fish_add_path -gp ~/.local/bin ~/.cargo/bin ~/.local/share/bob/nvim-bin

# .NET SDK, when it is a per-user install under ~/.dotnet. The test is for the
# binary rather than the directory, because the directory is not evidence of
# anything: a system-packaged dotnet creates ~/.dotnet itself to hold first-use
# sentinels, so it exists on machines with no per-user SDK at all and would
# point DOTNET_ROOT at a root holding no runtime. That is this machine today.
if test -x ~/.dotnet/dotnet
    set -gx DOTNET_ROOT ~/.dotnet
    fish_add_path -gp $DOTNET_ROOT $DOTNET_ROOT/tools
end

set -gx EDITOR nvim
set -gx VISUAL nvim

# Read by sudoedit alone, where it outranks VISUAL and EDITOR. It carries an
# absolute path where those two keep the bare name: they are read by git,
# crontab and everything else that spawns an editor, each of which should
# resolve the name freshly against the PATH of the moment. sudo documents the
# environment it hands the editor but not the PATH it searches, so a bare name
# there would rest on an undocumented detail. Resolved after the prepends above
# so a bob-installed nvim is found.
set -l nvim_path (command -v nvim)
if test -n "$nvim_path"
    set -gx SUDO_EDITOR $nvim_path
end

# Advertise 24-bit color to programs that gate on COLORTERM: delta, bat, fzf,
# supports-color in Node, rich in Python. terminfo cannot carry the answer,
# because TERM is xterm-256color and its colors# capability is 256, and TERM
# travels over ssh. Named only where the terminal is known to support it, and
# never over a value something else already set: claiming truecolor on a bare
# tty is worse than saying nothing, because a program that believes the claim
# emits escapes the terminal then draws as literal text.
if not set -q COLORTERM
    if set -q WT_SESSION; or set -q WEZTERM_EXECUTABLE; or set -q KITTY_WINDOW_ID
        set -gx COLORTERM truecolor
    else if test "$TERM_PROGRAM" = vscode; or test "$TERM_PROGRAM" = iTerm.app
        set -gx COLORTERM truecolor
    end
end

# Ask for the bright palette slots outright instead of relying on the terminal
# to promote bold to bright. Windows Terminal does that promotion; herdr renders
# bold as weight and keeps the normal slot, so the same listing came out darker
# inside herdr.
if type -q dircolors
    set -gx LS_COLORS (string replace -a '=01;3' '=01;9' -- (dircolors -b | string match -rg "LS_COLORS='([^']*)'"))
end
