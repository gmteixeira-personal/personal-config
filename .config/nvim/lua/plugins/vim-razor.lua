-- Razor syntax highlighting: the markup half of a .razor buffer, which the language server does
-- not colour.
--
-- roslyn.nvim attaches Roslyn to these buffers and Roslyn answers with semantic tokens, but those
-- tokens describe C# only -- identifiers, types, keywords, the contents of an @code block. The
-- HTML around them carries no token, so tags, attributes, values and the doctype came through as
-- undifferentiated plain text. This plugin is a plain Vim syntax file and fills exactly that gap:
-- it colours the whole file, and Roslyn's semantic tokens draw over the C# regions at a higher
-- priority than syntax, so the two layers compose rather than fight.
--
-- Every group it defines links to a standard highlight group -- Special, Keyword, String,
-- Delimiter, PreProc, Comment, Type -- so it takes its colours from whichever colorscheme Themery
-- has applied, with nothing to configure per theme.
--
-- It also ships an indent file and an ftplugin (which sources ftplugin/html.vim and sets
-- 'commentstring' to @*%s*@, the Razor comment form), and an ftdetect that is redundant here:
-- Neovim 0.12 already resolves .razor and .cshtml to the razor filetype on its own.
--
-- This does not reverse the no-tree-sitter decision. There is no parser and no parser plugin; this
-- is the regex syntax stack Neovim ships with, which every other filetype here already uses.
return {
  "jlcrochet/vim-razor",
  ft = { "razor" }, -- Nothing to load until a razor buffer exists. lazy.nvim re-fires FileType
  -- after putting the plugin on the runtimepath, which is what makes 'syntax' resolve on the
  -- buffer that triggered the load rather than only on the next one.
}
