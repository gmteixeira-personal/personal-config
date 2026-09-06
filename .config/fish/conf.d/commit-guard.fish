# Report a commit guard that is not running.
#
# .githooks/pre-commit is the last barrier between $HOME and a public remote,
# and git clones neither hooks nor repository-local config -- so it is switched
# on by hand in every environment, by the command named below, and a missed step
# leaves a repository where commits succeed exactly as they do with the guard
# running. It was found unset here, with no record of when: two commits had
# already landed without it. Nothing leaked, which was luck.
#
# Silent when the guard is active, which is every prompt on a machine that was
# set up correctly. A message that is always there is one nobody reads.
#
# Both halves are checked, because either half failing has the same effect: the
# hooks path has to name the tracked directory, and the hook in it has to be
# executable. Tracked content carries the mode bit, but not every route into a
# working tree preserves it, and git skips a non-executable hook without a word.
#
# The check reports; it does not fix. A startup file that quietly writes
# repository configuration would mask this same failure wherever the write did
# not take, and would run against every clone of every kind.
#
# Note the quoted "$(...)": a bare (...) expands to no arguments at all when git
# prints nothing, which leaves `test` with two arguments and an error -- and
# printing nothing is exactly the unset case this file exists to catch.
#
# Its own file because a security check is none of the four categories the
# startup-file layout names, and that layout gives a setting of a new kind a
# file of its own; conf.d/greeting.fish states the same rule for itself. The
# interactivity guard is here for the same reason: nothing in a script's fish
# has a reader for this.
if status is-interactive; and test -e $HOME/.git
    if test "$(git -C $HOME config --get core.hooksPath)" != .githooks
        or not test -x $HOME/.githooks/pre-commit
        set_color $fish_color_error
        echo "commit guard is not active -- $HOME/.githooks/pre-commit is not running"
        set_color normal
        echo "  activate:  git -C $HOME config core.hooksPath .githooks"
    end
end
