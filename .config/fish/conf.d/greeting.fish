# Silence the two-line "Welcome to fish" banner. fish composes it only because
# fish_greeting is unset; setting the variable to an empty string is the switch
# fish itself documents, and it leaves the function alone -- so the private-mode
# notice, which fish appends to this same variable, still gets through, and so
# does anything a future fish routes the same way.
#
# A global rather than a universal, which is the advice usually given. `set -U`
# writes to fish_variables, which is machine-local and deliberately untracked, so
# the banner would be silent here and loud on a clone. In this file the setting
# travels with the repository, and a global is read in preference to a universal,
# so a fish_greeting left behind in some machine's fish_variables cannot bring the
# banner back.
#
# Its own file because a greeting is none of the four categories the startup-file
# layout names -- environment, key bindings, shorthands, functions -- and that
# layout gives a setting of a new kind a file of its own. conf.d/tide.fish and
# conf.d/direnv.fish are the precedents. The guard is here for the same reason:
# the layout requires interactive-only configuration to carry one, and nothing in
# a script's fish ever calls fish_greeting.
if status is-interactive
    set -g fish_greeting ''
end
