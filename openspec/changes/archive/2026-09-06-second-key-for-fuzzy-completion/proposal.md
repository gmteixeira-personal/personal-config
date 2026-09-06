## Why

The fuzzy completion picker is bound to Shift+Tab, and Shift+Tab is the one key among the four fzf bindings that a terminal can consume before fish ever sees it. Whether it arrives depends on the terminal's keyboard protocol and on what else is between the keypress and the shell — a multiplexer, a remote session, a terminal that encodes modified Tab as plain Tab. When it does not arrive the failure is not an error: the completion that opens is fish's own prefix-matching one, which is a plausible thing to have happened and gives the user no reason to think a binding is missing.

The `fuzzy-finder` specification already treats this class of problem as real for a different key. `fish-key-bindings` requires that where a key reaches the shell under more than one encoding, the action is bound under every one of them, because a terminal must not be a silent precondition of a capability. Shift+Tab is the same argument arriving from the other direction: rather than one action under several encodings, it is one action needing a second key, because the first cannot be relied on to arrive at all.

There is a second reason that is about reach rather than reliability. The three pickers sit on Ctrl+T, Ctrl+R and Alt+C — one modifier, one finger. The completion picker, which is the one used mid-command and therefore the most often, is the only one that asks for a two-hand stretch.

## What Changes

- Ctrl+P becomes a second key for the fuzzy completion picker, in fish's default binding set and in vi insert mode, alongside the existing Shift+Tab. Neither key replaces the other.
- The cost is recorded in the file that pays it: Ctrl+P is preset to `up-line`, which moves the cursor between the lines of a multi-line command. Up still leaves such a command, so the function that key had is reachable.
- The `fuzzy-finder` spec's completion requirement stops saying "a key" and starts saying what has to be true of the set of keys, so that a binding lost to a terminal is a covered case rather than an accident this configuration happened to survive.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `fuzzy-finder`: The capability requires that fuzzy completion is available on a key, singular, and says nothing about what happens when that key does not reach the shell. Every other requirement in it is careful about exactly this kind of silent absence — a finder that is not installed, a binding cleared by a mode switch, a key claimed by the prompt plugin. This is the same failure with a different cause, and the requirement is widened to cover it.

## Impact

- `.config/fish/conf.d/fzf.fish` — two `bind` lines and the comment block above them, which already explains the reasoning and the cost.
- `openspec/specs/fuzzy-finder/spec.md` — one requirement restated.
- Behaviour: Shift+Tab is unchanged where it works. On a terminal where it does not, the picker is reachable for the first time. The preset `up-line` on Ctrl+P is displaced.
- Not changed: the three pickers, fish's own completion key, and the bash side. This is one action gaining one key.
