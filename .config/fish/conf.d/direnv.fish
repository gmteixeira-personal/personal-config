# direnv, hooked into fish. It watches PWD and applies whatever the nearest
# approved .envrc declares, then restores the environment it captured on the way
# back out -- which is how a project's .venv stops outliving the directory that
# declared it.
#
# Its own file rather than a line in env.fish: this is a new kind of setting, and
# conf.d/tide.fish is the precedent for a file outside the four named categories.
# Guarded here rather than by where the file sits, because conf.d is read by
# every fish -- a script or tool runner that changes directory should see no
# environment appear or disappear on its behalf.
#
# The type check is what makes the machine-level dependency optional. Without it
# a machine that has no direnv would print "Unknown command" on every shell
# start; with it the hook is simply absent and environments are activated by
# hand, which is the behaviour that predates this file.
if status is-interactive; and type -q direnv
    direnv hook fish | source
end
