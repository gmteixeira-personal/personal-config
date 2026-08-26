## REMOVED Requirements

### Requirement: `<leader>ft` previews and switches colorscheme

**Reason**: Choosing a colorscheme stops being a fuzzy-finder feature. Telescope's colorscheme picker cannot record what is accepted, which is the point of this change, so the mapping moves to a dedicated theme switcher with its own capability. Leaving the Telescope entry in place would bind `<leader>ft` twice and give the two pickers contradictory persistence behavior.

**Migration**: None for the user: `<leader>ft` still opens a colorscheme picker with live preview, and it is still the only key involved. What it opens is now the theme switcher, specified by `theme-switcher`, and accepting an entry there persists it. The mapping is redeclared in the theme switcher's own plugin file rather than in the fuzzy finder's, so `<leader>f` remains unbound in its own right and every other `<leader>f` picker is unchanged.
