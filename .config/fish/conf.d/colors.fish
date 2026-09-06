# Syntax highlighting and the completion pager, in 24-bit values.
#
# fish's own defaults name colours -- `red`, `brcyan`, `brblack` -- and a name is
# a palette index: fish emits SGR 31 or 96 and the terminal answers from its own
# theme. So the command line rendered in whatever colours the terminal shipped,
# which is the same problem LS_COLORS had in conf.d/env.fish and which
# conf.d/tide.fish never had, because every tide_* colour is already hex.
#
# The values below are not a theme. Each is what the name it replaces resolves
# to under foot 1.27's shipped "starlight V4" palette -- `man 5 foot.ini`, the
# defaults for regular0..7 and bright0..7 -- so nothing on screen changes; it
# just stops being a question. .config/vivid/themes/starlight.yml carries the
# same values for the listing.
#
# Globals rather than universals, for the reason conf.d/env.fish gives about
# `fish_add_path -g`: a universal lands in fish_variables, which is gitignored,
# and would then outlive an edit to this file.
#
# Its own file rather than lines in env.fish, on the precedent conf.d/tide.fish
# sets and conf.d/fzf.fish cites: prompt appearance is a subject of its own, and
# env.fish is the environment a non-interactive shell needs too.
#
# The variables fish leaves as bare attributes -- fish_color_normal, _command,
# _host, _cancel, _history_current, _valid_path, and the pager's _prefix and
# _selected_background -- are not set here. They name no colour, so there is
# nothing to translate, and restating them would only pin them against a fish
# release that changes them.
if status is-interactive
    # regular1 f62b5a, regular2 47b413, regular3 e3c401, regular6 13c299,
    # regular7 e6e6e6; bright0 616161, bright1 ff4d51, bright2 35d450,
    # bright6 24dfc4, bright7 ffffff.
    set -g fish_color_autosuggestion 616161
    set -g fish_color_comment f62b5a
    set -g fish_color_cwd 47b413
    set -g fish_color_cwd_root f62b5a
    set -g fish_color_end 47b413
    set -g fish_color_error ff4d51
    set -g fish_color_escape 24dfc4
    set -g fish_color_host_remote e3c401
    set -g fish_color_operator 24dfc4
    set -g fish_color_param 13c299
    set -g fish_color_quote e3c401
    set -g fish_color_redirection 13c299 --bold
    set -g fish_color_search_match e6e6e6 --background=616161 --bold
    set -g fish_color_selection e6e6e6 --background=616161 --bold
    set -g fish_color_status f62b5a
    set -g fish_color_user 35d450

    set -g fish_pager_color_description e3c401 --italics
    set -g fish_pager_color_progress ffffff --background=13c299 --bold
end
