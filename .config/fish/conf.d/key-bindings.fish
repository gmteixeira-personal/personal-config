# Key bindings. Interactive only: a shell with no reader has nothing to bind,
# and the guard lives here rather than in a caller so that removing any other
# startup file cannot take it away.
if status is-interactive
    fish_vi_key_bindings

    # fish calls this once at the end of interactive start-up, after the
    # binding set above is installed, so what is bound here is what a key
    # resolves to at a prompt. Measured on fish 4.8.1, and not what an earlier
    # version of this comment claimed: `fish_vi_key_bindings` does not call this
    # function, and the `bind --erase --all --preset` it opens with erases only
    # preset bindings, so a custom binding survives a mode switch wherever it is
    # made. This is where they are collected anyway -- one place to look, and
    # bindings only, so that changing them cannot take anything else with them.
    function fish_user_key_bindings
        bind -M default \cf forward-word
        bind -M insert \cf forward-word

        bind -M default \cb backward-kill-word
        bind -M insert \cb backward-kill-word

        # Accept the autosuggestion and run it in one keystroke. The key this is
        # for is Ctrl+Enter; ctrl-j is what the terminal actually delivers when
        # it is pressed, measured with fish_key_reader in WezTerm on this
        # machine -- the terminal sends a bare LF, 0x0A, rather than encoding
        # the modifier, and 0x0A is ctrl-j. Plain Enter arrives separately as
        # `enter`, so the two are distinguishable and Ctrl+Enter is reachable;
        # it just is not spelled `ctrl-enter` here. Ctrl+J does the same thing
        # as a consequence, which one byte for two chords makes unavoidable.
        #
        # Written as `ctrl-j` rather than the `\cj` of the bindings above
        # because this is the line whose key is the whole point of it, and the
        # name says which chord to press where the escape does not.
        bind -M default ctrl-j accept-autosuggestion-and-run
        bind -M insert ctrl-j accept-autosuggestion-and-run
    end

    # The bindings above lose ctrl-j to tide, and this puts it back.
    #
    # tide's transient prompt binds \r and \n at file scope in
    # functions/fish_prompt.fish, and \n is the same byte as ctrl-j. fish
    # autoloads that file when the prompt function is first called, which is
    # after conf.d and after fish_user_key_bindings, so tide's binding replaces
    # the one above and Ctrl+Enter runs the line without accepting the
    # suggestion -- indistinguishable from plain Enter, and the reason this
    # binding appeared not to exist at all.
    #
    # Measured: fish has not autoloaded that file at the first fish_prompt
    # event, and has by the second -- it loads it in between, to draw prompt
    # one. Simply binding here would therefore bind ahead of tide and be
    # overwritten straight after, leaving the first prompt of every session with
    # tide's binding; waiting for the second event instead leaves that same
    # first prompt wrong. So the load is pulled forward rather than waited on:
    # asking for the function's definition is what makes fish autoload it, and
    # once it has, tide's bindings are installed and can be bound over.
    #
    # This has to happen here and not in conf.d. Snippets are read in filename
    # order, tide.fish sorts after this file, and it is what sets
    # tide_prompt_transient_enabled -- so forcing the load from conf.d would
    # source fish_prompt.fish while that variable was still unset, skip the
    # block guarded on it, and leave tide's transient prompt never bound to
    # Enter at all. By the first prompt every snippet has run and the variable
    # is set.
    #
    # Editing functions/fish_prompt.fish directly would be the obvious fix and
    # the wrong one: fisher owns that file and rewrites it on update, which
    # would revert the fix silently and leave the key quietly broken again.
    #
    # One shot: the ordering is a start-up problem, so this erases itself rather
    # than re-binding at every prompt forever.
    function _accept_and_run_after_tide --on-event fish_prompt
        functions fish_prompt >/dev/null 2>&1

        bind -M default ctrl-j accept-autosuggestion-and-run
        bind -M insert ctrl-j accept-autosuggestion-and-run

        functions -e _accept_and_run_after_tide
    end
end
