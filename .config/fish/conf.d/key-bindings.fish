# Key bindings. Interactive only: a shell with no reader has nothing to bind,
# and the guard lives here rather than in a caller so that removing any other
# startup file cannot take it away.
if status is-interactive
    fish_vi_key_bindings

    # fish calls this after every binding set is installed, including on a
    # later `fish_vi_key_bindings`, which clears the table first. Custom
    # bindings therefore have to be here to survive a mode switch -- and only
    # bindings, so that changing them cannot take anything else with them.
    function fish_user_key_bindings
        bind -M default \cf forward-word
        bind -M insert \cf forward-word

        bind -M default \cb backward-kill-word
        bind -M insert \cb backward-kill-word

        bind -M default \cj accept-autosuggestion execute
        bind -M insert \cj accept-autosuggestion execute
    end
end
