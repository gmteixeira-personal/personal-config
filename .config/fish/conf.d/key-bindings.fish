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
        # for is Ctrl+Enter, and which name it arrives under is a property of
        # the terminal, not of this machine -- so both names are bound and the
        # terminal stops being a precondition of the key working.
        #
        # A terminal speaking the kitty keyboard protocol encodes the modifier,
        # and fish 4 negotiates that protocol, so the press arrives as a key of
        # its own named `ctrl-enter`. Binding it is not optional there: fish
        # ships the preset `ctrl-enter execute`, so an unbound `ctrl-enter` is
        # not a key that does nothing but a key that runs the line without
        # accepting the suggestion -- indistinguishable from plain Enter, and
        # exactly how this binding failed once the session's terminal became
        # foot. A wrong action rather than an error is why it went unnoticed.
        #
        # A terminal without that protocol drops the modifier and sends a bare
        # LF, 0x0A, which is ctrl-j: measured with fish_key_reader under
        # WezTerm, whose kitty-protocol support sits behind
        # `enable_kitty_keyboard` and is off by default. Ctrl+J does the same
        # thing as a consequence, which one byte for two chords makes
        # unavoidable -- and it keeps doing it under the protocol, where the two
        # chords are finally distinct, because Ctrl+J is a chord someone can
        # press and this action is what it has always done.
        #
        # Written as key names rather than the `\cf`/`\cb` escapes above because
        # these are the lines whose keys are the whole point of them, and the
        # name says which chord to press where the escape does not.
        bind -M default ctrl-enter accept-autosuggestion-and-run
        bind -M insert ctrl-enter accept-autosuggestion-and-run

        bind -M default ctrl-j accept-autosuggestion-and-run
        bind -M insert ctrl-j accept-autosuggestion-and-run
    end

    # The bindings above lose ctrl-j to tide, and this puts it back.
    #
    # Only ctrl-j collides -- tide binds no protocol key name -- so ctrl-enter
    # is re-bound here for symmetry rather than necessity. The two lists are
    # read as a pair, and a reader who finds them different has to work out
    # which collision made them differ; two lines cost less than that. It also
    # means a future tide that binds ctrl-enter is already covered.
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

        bind -M default ctrl-enter accept-autosuggestion-and-run
        bind -M insert ctrl-enter accept-autosuggestion-and-run

        bind -M default ctrl-j accept-autosuggestion-and-run
        bind -M insert ctrl-j accept-autosuggestion-and-run

        functions -e _accept_and_run_after_tide
    end
end
