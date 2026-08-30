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
        bind -M insert \cj accept-autosuggestion execute
        function mkcd
            mkdir -p $argv[1]
            cd $argv[1]
        end

        function cl
            cd $argv[1]
            ls -lah
        end

        abbr la 'ls -A'
        abbr l1 'ls -1'
        abbr la1 'ls -A1'
        abbr ll 'ls -lh'
        abbr lla 'ls -lhA'
        abbr lla1 'ls -lhA1'
        abbr gaa 'git add --all'
        abbr gcm 'git commit -m'
        abbr gco 'git checkout'
        abbr grb 'git rebase'
        abbr gstash 'git stash'
        abbr gpull 'git pull'

        alias e nvim

    end
end
