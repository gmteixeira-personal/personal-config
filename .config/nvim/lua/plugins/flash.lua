-- Jump motions: any position visible on screen reached by typing what is there and pressing the
-- label that appears beside it. The same machinery serves five other things -- a remote operator
-- (yank or delete somewhere else on screen, cursor comes back), tree-sitter node selection and
-- search, f/t/F/T that advance on a second press, and a / search whose visible matches carry labels.
--
-- Three stock keys change meaning, all deliberately:
--   * normal-mode s (substitute character) becomes the jump. Substitute is cl.
--   * normal-mode S (linewise change) becomes tree-sitter node selection. Linewise change is cc.
--   * operator-pending r starts the remote jump, and operator-pending R the tree-sitter search.
--     Normal-mode r (replace character) is one keystroke away and is NOT touched -- an operator
--     has to be pending for either of these to fire.
-- Visual-mode S is left alone: it belongs to nvim-surround, which shadows it by design, and
-- surround-edits records that shadow. Node selection from a visual selection goes through R.
--
-- <C-s> is mapped in command-line mode only, so the <C-s> that writes the buffer in normal,
-- insert, and visual mode survives untouched.

-- The tree-sitter modes are guarded rather than called straight. vim.treesitter.get_parser()
-- raises when the buffer's language has no parser, Neovim 0.12's runtime ships parsers for a
-- handful of languages only (c, lua, markdown, query, vim, vimdoc), and nvim-treesitter is
-- deliberately absent from this configuration -- so every other buffer would answer S with a
-- stack trace. The guard turns that into one warning naming the filetype, and leaves the buffer,
-- the cursor, and the selection alone. The other four modes are unaffected in such a buffer.
local function has_parser()
  local ok = pcall(vim.treesitter.get_parser, 0)
  if not ok then
    local filetype = vim.bo.filetype
    vim.notify(
      ("Flash: no tree-sitter parser available for filetype %q"):format(filetype == "" and "none" or filetype),
      vim.log.levels.WARN
    )
  end
  return ok
end

local function treesitter()
  if has_parser() then
    require("flash").treesitter()
  end
end

local function treesitter_search()
  if has_parser() then
    require("flash").treesitter_search()
  end
end

return {
  "folke/flash.nvim",
  -- No version: upstream publishes no tags, so any constraint would resolve to nothing.
  -- lazy-lock.json is what pins the commit. No dependencies either -- the tree-sitter modes use
  -- the runtime bundled with Neovim 0.12, not a parser plugin.
  opts = {
    -- Only the three settings the spec leans on are spelled out. Their upstream defaults have
    -- moved across flash releases, and the spec now requires exactly these values; everything
    -- else -- label characters, backdrop, highlight groups, jump behaviour -- rides on upstream
    -- defaults on purpose, the same way nvim-surround takes opts = {} here.
    modes = {
      char = {
        enabled = true, -- f/t/F/T enhanced rather than left stock
        jump_labels = true, -- and their multiple targets labelled, not stepped through with ;
      },
      search = {
        enabled = true, -- / and ? label their visible matches
      },
    },
  },
  -- keys, matching how nvim-surround, telescope, vim-visual-multi, and conform load: nothing here
  -- is needed before it is first pressed.
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash: jump to position",
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Flash: remote operator",
    },
    { "S", mode = { "n", "o" }, treesitter, desc = "Flash: select syntax node" },
    { "R", mode = { "o", "x" }, treesitter_search, desc = "Flash: search to syntax node" },
    {
      "<C-s>",
      mode = "c",
      function()
        require("flash").toggle()
      end,
      desc = "Flash: toggle search labels",
    },
    -- Load triggers, not mappings flash asks to have declared. flash installs its character-motion
    -- and search hooks inside setup(), so without these entries f, t, F, T, / and ? stay stock
    -- until some other flash key has been pressed in the session. lazy.nvim holds a stub for each,
    -- loads the plugin on the first press, and replays the key into the mapping flash installed.
    -- ; and , are deliberately absent: before the plugin loads they already mean what flash makes
    -- them mean afterwards, so a stub would only load the plugin on a keystroke that did not need it.
    { "f", mode = { "n", "x", "o" }, desc = "Flash: find character forwards" },
    { "F", mode = { "n", "x", "o" }, desc = "Flash: find character backwards" },
    { "t", mode = { "n", "x", "o" }, desc = "Flash: till character forwards" },
    { "T", mode = { "n", "x", "o" }, desc = "Flash: till character backwards" },
    { "/", mode = { "n", "x" }, desc = "Flash: labelled search forwards" },
    { "?", mode = { "n", "x" }, desc = "Flash: labelled search backwards" },
  },
}
