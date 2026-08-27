-- General editor options only; a plugin's own settings live with it in lua/plugins/.

vim.g.mapleader = " " -- <leader> resolves when a mapping is defined, so this must precede plugins
vim.g.maplocalleader = "\\" -- explicit, so a future mapleader change cannot silently collide

vim.opt.termguicolors = true -- the themes' palettes need 24-bit color, not a 256-color approximation
vim.opt.background = "dark" -- kanagawa wave is a dark variant

-- Display
vim.opt.number = true -- absolute number on the cursor line, so position in the file is readable at a glance
vim.opt.relativenumber = true -- distance on every other line, so a vertical motion count reads straight off the screen
vim.opt.signcolumn = "yes" -- reserved permanently: "auto" lets a gitsigns or LSP sign shove the whole buffer sideways

-- Indentation: two columns, never a tab character
vim.opt.expandtab = true
vim.opt.shiftwidth = 2 -- one level for the shift commands
vim.opt.tabstop = 2 -- width a tab character already present in a file renders as
vim.opt.softtabstop = 2 -- what Tab inserts and Backspace removes; without it Backspace eats a single space
vim.opt.smartindent = true -- a line that opens a block indents the next one a level deeper

-- Search
vim.opt.ignorecase = true -- load-bearing for the line below: smartcase does nothing on its own
vim.opt.smartcase = true -- an upper-case character anywhere in the query makes it case-sensitive again
vim.opt.incsearch = true -- the match moves under the query as it is typed, so a wrong one can be abandoned early
vim.opt.hlsearch = true -- matches stay highlighted after the search is accepted, so a term's spread stays visible; <Esc> in lua/config/keymaps.lua is what dismisses them

-- Movement and splits
vim.opt.scrolloff = 999 -- the cursor is held at the middle of the window; the view scrolls under it
vim.opt.splitright = true -- the new window takes the new space and the existing one keeps its position
vim.opt.splitbelow = true

-- Persistence and timing
vim.opt.undofile = true -- undo survives closing the file; the default state directory is already outside every project
-- What :mksession records, so a restored session reproduces the layout and not just the file list.
-- `terminal` is absent: a restored terminal buffer re-runs nothing and comes back as a dead window.
-- `options` is absent in favour of `localoptions` alone: `options` persists global option values into
-- the session file, so a session saved today would silently override this file tomorrow -- the
-- per-window settings are worth keeping, the global ones belong here and nowhere else.
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"
vim.opt.updatetime = 250 -- how soon idle-triggered features fire, and also how often the swap file is written: a disk change, not only a UI one
vim.opt.timeoutlen = 1000 -- Neovim's default. The window is between keys, not for the whole sequence, so multi-key <leader> mappings can be typed at a comfortable pace; the cost is that an abandoned prefix stays pending for a full second

-- Wrapping: display only, the file on disk is untouched
vim.opt.wrap = true -- the two below are inert without it, which is why the three are set together
vim.opt.linebreak = true -- break at a word boundary rather than mid-word
vim.opt.breakindent = true -- continuation rows align with the wrapped line's own indentation

vim.opt.autoread = true -- a file changed on disk is reloaded when Neovim next checks it, unless the buffer has unsaved changes

-- Clipboard
vim.opt.clipboard = "unnamedplus" -- routes yank and delete through + without the register having to be named

-- Supply a mechanism only where Neovim found none. Asking the provider, rather than testing
-- for WSL, is what stops this replacing a faster tool Neovim already chose: under WSLg with
-- xclip installed the detection below is never reached.
--
-- Deferred, because asking costs ~60 ms on WSL: every executable() miss in Neovim's detection
-- chain stats the /mnt/c directories on $PATH. Neovim resolves the provider lazily on first
-- use, so nothing needs this answer during startup, and running it a tick later keeps launch
-- at its ~39 ms baseline instead of ~98 ms.
vim.schedule(function()
  if vim.fn["provider#clipboard#Executable"]() == "" then
    if vim.fn.executable("clip.exe") == 1 and vim.fn.executable("powershell.exe") == 1 then
      -- Neovim ships this pair already; its own branch misses here only because it tests for
      -- `clip` and `powershell` without the .exe suffix WSL exposes them under.
      vim.g.clipboard = {
        name = "wsl-clip",
        copy = {
          ["+"] = { "clip.exe" }, -- takes LF input as-is, so the copy side needs no treatment
          ["*"] = { "clip.exe" },
        },
        paste = {
          -- Get-Clipboard returns CRLF and appends a trailing blank line; run through a shell
          -- to strip both, or every pasted line ends in a ^M. A list is required: a string
          -- command is split on spaces and executed with no shell, which would lose the pipe.
          ["+"] = {
            "sh",
            "-c",
            "powershell.exe -NoProfile -NoLogo -Command Get-Clipboard | sed -e 's/\\r$//' -e '${/^$/d}'",
          },
          ["*"] = {
            "sh",
            "-c",
            "powershell.exe -NoProfile -NoLogo -Command Get-Clipboard | sed -e 's/\\r$//' -e '${/^$/d}'",
          },
        },
        -- Serve text yanked in the editor from Neovim's cache instead of a ~180 ms PowerShell
        -- round trip. Unlike xclip, clip.exe exits instead of owning the selection, so the cache
        -- lasts only while it lives; it still halves the cost of the copy itself.
        cache_enabled = true,
      }
      -- Executable() above cached what it resolved (nothing) in the provider's script scope, so
      -- the assignment lands too late to be seen. This is the provider's own documented reload.
      vim.g.loaded_clipboard_provider = nil
      vim.cmd("runtime autoload/provider/clipboard.vim")
    end
  end
end)
