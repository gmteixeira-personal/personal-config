## 1. Hand the Roslyn binary to mason-tool-installer

- [x] 1.1 Remove `roslyn_ls` from the `servers` table in `lua/plugins/mason-lspconfig.lua`, and confirm the remaining nine entries are untouched.
- [x] 1.2 Update the comment beside that list where it explains the C# entry, so the file does not describe a server it no longer declares.
- [x] 1.3 Add `roslyn-language-server` to `ensure_installed` in `lua/plugins/mason-tool-installer.lua`, noting in a comment that it is a server rather than a formatter and that it lives here because roslyn.nvim enables it, so it must be installed without being auto-enabled.
- [x] 1.4 Confirm the package is not reinstalled or removed on next launch — it is already on disk at 5.11.0-1.26380.4 and only its declaring file changed.

## 2. Add the plugin

- [x] 2.1 Create `lua/plugins/roslyn.lua` with the `seblyng/roslyn.nvim` spec, following the file conventions the other plugin specs use — a header comment saying what the file owns and why, and `opts` rather than a `config` function where opts suffice.
- [x] 2.2 Leave `broad_search` at its default `false`, and record in the comment that this is deliberate: it walks parent directories for solutions, which is the behaviour the `tailwindcss` root_dir override exists to prevent.
- [x] 2.3 Point the plugin at the mason-installed binary if it does not find `roslyn-language-server` on its own — mason's `bin/` is on the path Neovim sees, so verify before adding a `cmd` override rather than adding one pre-emptively.
- [x] 2.4 Confirm no `vim.lsp.config("roslyn_ls", ...)` or `vim.lsp.enable("roslyn_ls")` call remains anywhere in `lua/`.

## 3. Verify C# still works

- [x] 3.1 Open a `.cs` file in a project with a `.sln` or `.csproj` and confirm a server attaches.
- [x] 3.2 Run `:lua =vim.lsp.get_clients()` in that buffer and confirm exactly one Roslyn client is running, not two. This is the failure mode the change is most likely to introduce.
- [x] 3.3 Confirm completion, `gd`, `K`, and diagnostics all still work in that buffer.

## 4. Verify Razor

- [x] 4.1 Open a `.razor` file in the same project and confirm `:set filetype?` reports `razor` and a server attaches.
- [x] 4.2 Confirm the buffer is highlighted — markup, C# expressions, and the `@code` block visually distinct rather than uniform plain text.
- [x] 4.3 Confirm completion offers C# symbols inside an `@code` block and component or attribute names in the markup.
- [x] 4.4 Introduce a deliberate error in the `@code` block and confirm a diagnostic appears inline and in the sign column.
- [x] 4.5 Repeat 4.1 and 4.2 for a `.cshtml` file.
- [x] 4.6 Confirm opening the C# file and the Razor file in either order still leaves exactly one Roslyn client running.

## 5. Verify nothing else regressed

- [x] 5.1 Open a `.razor` file outside any C# project and confirm the buffer is editable and no error is raised, even though no server attaches.
- [x] 5.2 Open a Lua, a TypeScript and a Python file and confirm their servers still attach — the `servers` list was edited and the allowlist derives from it.
- [x] 5.3 Run `:checkhealth lsp` and confirm no new errors, and that any warnings are the known external prerequisites already recorded.
- [x] 5.4 Run `:Lazy` and confirm roslyn.nvim installed cleanly with no load error.

## 6. Highlight the markup

- [x] 6.1 Create `lua/plugins/vim-razor.lua` with the `jlcrochet/vim-razor` spec, lazy on `ft = { "razor" }`, and a header comment saying which half of the highlighting it owns and why the server cannot cover it.
- [x] 6.2 Confirm the syntax reaches the buffer that triggered the load, not only the next one — open a razor file cold and check `:set syntax?` reports `razor` and `b:current_syntax` is set.
- [x] 6.3 Confirm the markup groups resolve on a real file: tag start, tag name, tag end, attribute, attribute operator, value delimiter, value, and the doctype.
- [x] 6.4 Confirm an `@` expression inside an attribute value is still highlighted as razor and C# rather than swallowed by the surrounding string.
- [x] 6.5 Confirm the plugin stays unloaded when no razor buffer has been opened.
- [x] 6.6 Open a razor file outside any C# project and confirm it is fully highlighted with no client attached — this is the case the previous pass left plain.
- [x] 6.7 Open a razor file inside a project, wait for Roslyn to attach, and confirm its semantic tokens still win inside the C# regions rather than being masked by the syntax layer.

## 7. Close out

- [x] 7.1 Run `openspec validate add-razor-support --strict` and confirm it passes.
