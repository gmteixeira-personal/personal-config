## 1. Display and colours

- [x] 1.1 In `lua/config/options.lua`, set `number` and `relativenumber` both true, below the existing leader assignments. Keep the file a flat list of `vim.opt` assignments with a comment per group saying *why*, not restating the option name — no table-driven loop, no helper function.
- [x] 1.2 Leave the existing `termguicolors` and `background` lines exactly as they are, comments included. They already hold the proposed values; the spec names them so the capability is complete, but implementing them is a no-op and rewriting them would produce a diff with no behaviour behind it.
- [x] 1.3 Set `signcolumn = "yes"`, not `"auto"`. `"auto"` produces precisely the horizontal jitter this setting exists to remove, and with gitsigns and the LSP both attaching on `BufReadPre` that jitter would occur on nearly every file in a git repository.
- [x] 1.4 Verify line numbers: the cursor's own line shows its absolute number while every other line shows its distance from the cursor, and both update as the cursor moves.
- [x] 1.5 Verify the sign column is reserved in a buffer with no signs at all, and that text does not shift horizontally when gitsigns marks a line in a git repository.

## 2. Indentation

- [x] 2.1 Set `expandtab` true, and `shiftwidth`, `tabstop` and `softtabstop` all to 2. All three matter and none is redundant: they govern a shift command, a rendered tab character, and the Tab/Backspace keys respectively.
- [x] 2.2 Set `smartindent` true, so a new line after one opening a block is indented a level deeper.
- [x] 2.3 Verify inserting: pressing Tab in insert mode inserts two spaces and writes no tab character to the file.
- [x] 2.4 Verify shifting and removing: shifting a line moves it by two columns, and pressing Backspace against indentation removes a full two-column level rather than one space.
- [x] 2.5 Verify continuation: opening a new line after a line that begins a block indents it one level deeper automatically.

## 3. Search

- [x] 3.1 Set `ignorecase` and `smartcase` together. `smartcase` has no effect without `ignorecase`, so setting either alone is a bug — note that in the comment.
- [x] 3.2 Set `incsearch` true and `hlsearch` false.
- [x] 3.3 Verify case handling: an all-lower-case query matches regardless of case, and a query containing an upper-case character matches case-sensitively.
- [x] 3.4 Verify feedback while typing: a partially typed query already shows and moves to the first match, the display updates per keystroke, and cancelling the search returns the cursor to where it started.
- [x] 3.5 Verify no lingering highlight: after accepting a search and resuming editing, no matches remain highlighted and no command is needed to clear one.

## 4. Movement and splits

- [x] 4.1 Set `scrolloff = 8`.
- [x] 4.2 Set `splitright` and `splitbelow` true.
- [x] 4.3 Verify scrolling: moving down through a file longer than the window keeps at least eight lines visible below the cursor, and the cursor still reaches the final line of the file without blank space being scrolled in past the end.
- [x] 4.4 Verify splits: a vertical split places the new window to the right and a horizontal split places it below, with the original window keeping its position.

## 5. Persistence and timing

- [x] 5.1 Set `undofile` true. Do not set `undodir` — the default under `stdpath("state")` is already outside every project, which is what the spec requires.
- [x] 5.2 Set `updatetime = 250`. Note in the comment that this also raises how often the swap file is written, so the change is not purely a UI one.
- [x] 5.3 Set `timeoutlen = 300`, with a comment recording the trade: it makes `<Space>` feel immediate, at the cost of every two- and three-key `<leader>` mapping having to be typed as a deliberate sequence.
- [x] 5.4 Verify persistent undo: edit and save a file, quit, reopen the same file, and confirm the previous session's edit can still be undone.
- [x] 5.5 Verify undo storage: no undo-history file is created beside the edited file in its own directory, and opening a file with no stored history raises no error.
- [x] 5.6 Verify the timeout in both directions: a `<leader>` sequence typed deliberately still triggers its mapping, and a prefix typed then abandoned stops waiting within a third of a second.

## 6. Wrapping

- [x] 6.1 Set `wrap` true, together with `linebreak` and `breakindent`. Record in the comment that the latter two are inert unless `wrap` is on, which is why all three are set together.
- [x] 6.2 Verify a line wider than the window is shown across several screen rows with no horizontal scrolling, the break falls at a word boundary with no word split across rows, and an indented line's continuation rows align with its own indentation.
- [x] 6.3 Verify wrapping is display-only: the file's contents are unchanged, and `j`/`k` move over the whole logical line rather than one screen row. Confirm no `j`/`k` remapping was added — that is a keymap and a non-goal of this change.

## 7. External changes

- [x] 7.1 Set `autoread` true.
- [x] 7.2 Verify a file changed on disk by another program is picked up in an unmodified buffer when the editor next checks it, and that a buffer holding unsaved changes is not silently replaced but reported as a conflict.

## 8. Clipboard

- [x] 8.1 Set `clipboard = "unnamedplus"` unconditionally — it is correct on every platform and is what routes yank and delete through the `+` register.
- [x] 8.2 Guard the provider on Neovim's own answer, not on the environment: supply one only when `vim.fn["provider#clipboard#Executable"]()` returns an empty string. Run the guard on a deferred `vim.schedule` tick rather than during startup — asking eagerly costs ~60 ms on WSL, where each `executable()` miss in Neovim's detection chain stats the `/mnt/c` directories on `$PATH`. Nothing needs the answer before the first clipboard use. A `has("wsl")` guard is wrong and must not be used — under WSLg with `xclip` installed Neovim has already chosen a faster native tool, and a WSL-keyed override would replace it, which `specs/editor-options` forbids.
- [x] 8.3 Inside that guard, and only when `clip.exe` and `powershell.exe` are both executable, set `vim.g.clipboard` with copy via `clip.exe` and paste via `powershell.exe -NoProfile -NoLogo -Command Get-Clipboard`. This is Neovim's own shipped `clip` provider; its built-in branch fails here only because it tests for `clip` and `powershell` without the `.exe` suffix WSL uses.
- [x] 8.4 Normalise the paste side: `Get-Clipboard` returns CRLF line endings and appends a trailing newline, so run the paste command through a shell that strips carriage returns and drops the trailing blank line. Give the command as a list, `{ "sh", "-c", … }`: `s:split_cmd()` splits a string command on spaces and runs it with no shell, which would hand the `|` to PowerShell as an argument. Without this every pasted line ends in a `^M`. The copy side needs no treatment — `clip.exe` accepts LF input as-is.
- [x] 8.5 Set `cache_enabled` so text yanked inside the editor is served from Neovim's cache rather than paying ~220 ms to ask Windows for something the editor already knows.
- [x] 8.6 Resolve the one thing that cannot be settled by reading: confirm that assigning `vim.g.clipboard` *after* `provider#clipboard#Executable()` has already run is actually honoured. Exercised, and it is not: without re-initialisation the provider reports `has('clipboard') = 0` and yanking raises `clipboard: No provider`. `provider#clipboard#Init()` does not exist in Neovim 0.12.5 — the provider ships only `Error()`, `Executable()` and `Call()` — so use the provider file's own documented reload instead: clear `g:loaded_clipboard_provider`, then `runtime autoload/provider/clipboard.vim`.
- [x] 8.7 Verify copying out: yank text in the editor, paste into another application, and confirm the yanked text arrives.
- [x] 8.8 Verify pasting in: copy multi-line text in another application, paste in the editor without naming a register, and confirm the text is inserted with no `^M` at any line end and no extra blank line at the end.
- [x] 8.9 Verify delete also copies, and that a paste of text yanked inside the editor does not pay the PowerShell round trip.
- [x] 8.10 Verify the guard does not fire where it must not: with a clipboard tool Neovim recognises available, confirm `vim.g.clipboard` is left unset and the editor's own choice is used. Confirm by inspection that on a native Linux terminal with a tool installed this branch cannot be reached.
- [x] 8.11 Verify the no-clipboard-at-all path: where neither Neovim's detection nor this configuration can reach a clipboard, the editor starts normally, every buffer is editable, yank and delete still work in the editor's own registers, and the absence surfaces in `:checkhealth` rather than as an error on every yank.

## 9. Cross-cutting

- [x] 9.1 Confirm the ownership rule held: `lua/config/options.lua` is the only file this change edited. No file under `lua/plugins/` was touched, no keymap was added anywhere, and `init.lua` is unchanged.
- [x] 9.2 Confirm the standalone rule held: `lua/config/options.lua` loads with zero plugins installed and references no plugin module. Check by loading it with the plugin directory moved aside, not by reading it.
- [x] 9.3 Confirm no option in this change is also set in a plugin file, and that the clipboard block is the only conditional in the file.
- [x] 9.4 Run `:checkhealth` and confirm nothing regressed against the tooling change's baseline — mason, telescope, gitsigns and the LSP sections report no new errors, and any clipboard warning reflects the real state of the machine.
- [x] 9.5 Confirm startup is not measurably slower than before the change, given that the clipboard guard runs on every launch. Measured over 15 runs per variant: 39 ms before the change, 103 ms with the guard eager, 39 ms with it deferred to a `vim.schedule` tick. The deferral is what makes this pass; the cost is WSL-specific and disappears entirely with `/mnt/c` off `$PATH`.
