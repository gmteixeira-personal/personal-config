if status is-interactive
    # Enable Vi key bindings
    fish_vi_key_bindings

    # Custom bindings must go in this specific function when using Vi mode
    function fish_user_key_bindings
        bind -M default \cf forward-word
        bind -M insert \cf forward-word

        bind -M default \cb backward-kill-word
        bind -M insert \cb backward-kill-word

        bind -M default \cj accept-autosuggestion execute
        bind -M insert  \cj accept-autosuggestion execute
    end
end

# Your custom aliases and functions
function ll
    ls -lh $argv
end

alias lla="ll -a"

