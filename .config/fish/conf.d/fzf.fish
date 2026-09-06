# fzf, the fuzzy finder, wired into the command line: Ctrl+T picks a file into
# the line, Ctrl+R picks a command out of history, Alt+C changes directory, and
# Shift+Tab runs the current token's completions through the picker. Ctrl+P is a
# second key for that last one, because Shift+Tab is the one key here a terminal
# can swallow before fish sees it, and because the completer is worth a key that
# needs no reach. It costs the preset `up-line`, which only moves the cursor
# between the lines of a multi-line command; Up still leaves such a command.
#
# Its own file rather than a line in env.fish, for the same reason direnv.fish
# is: this is a new kind of setting, and conf.d/tide.fish is the precedent for a
# file outside the four named categories.
#
# Generated rather than transcribed. `fzf --fish` is some four hundred lines of
# widget that fzf rewrites on every release; pasting it here would pin both the
# widget set and the key choices to whichever version happened to produce it.
#
# The type check is what makes the machine-level dependency optional. Without it
# a machine with no fzf would print "Unknown command" on every shell start; with
# it the widgets are simply absent, which is the behaviour that predates this
# file. Interactive only, and guarded here rather than by where the file sits,
# because conf.d is read by every fish and a script has no reader to press a key.
#
# Self-contained, including the bindings, which is worth saying because
# conf.d/key-bindings.fish is read after this file -- f sorts before k -- and
# opens by installing the vi binding set. Measured on fish 4.8.1: that set's
# `bind --erase --all --preset` erases preset bindings only, and a user binding
# outranks a preset on the same key, so all five keys above still answer at the
# prompt and still answer after a mode switch. Nothing has to be re-issued from
# fish_user_key_bindings, and nothing here depends on another snippet.
if status is-interactive; and type -q fzf
    fzf --fish | source
    bind ctrl-p fzf_complete
    bind -M insert ctrl-p fzf_complete
end
