# Command shorthands. Both mechanisms live here because they are one subject:
# `abbr` expands at the prompt and leaves the real command in history, which is
# what shorthands for a command plus flags want; `alias` is used where the name
# should stay the name in history, and defines a function rather than an
# expansion.
#
# Interactive only, and guarded here rather than by where the file sits: a
# script that runs `ll` should fail on the missing command instead of finding
# whatever this file happens to define today.
if status is-interactive
    abbr la 'ls -A'
    abbr l1 'ls -1'
    abbr la1 'ls -A1'
    abbr ll 'ls -lh'
    abbr lla 'ls -lhA'
    abbr lla1 'ls -lhA1'

    abbr gaa 'git add --all'
    abbr gcm 'git commit -m'
    abbr gc 'git commit'
    abbr gco 'git checkout'
    abbr grb 'git rebase'
    abbr grs 'git restore --staged'

    alias e nvim

    # A deliberate override, not a shorthand: the name stays `cat` and the
    # reader gets highlighting, line numbers, and a pager for anything longer
    # than a screen. bat prints plain when its output is not a terminal, so a
    # pipeline behaves as it always did, and `command cat` reaches the original.
    # Guarded, so a machine without bat keeps plain cat and says nothing.
    type -q bat; and alias cat bat
end
