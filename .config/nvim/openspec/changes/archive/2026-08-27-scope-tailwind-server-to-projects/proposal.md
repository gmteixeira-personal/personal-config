## Why

Opening `~/README.md` froze the editor. The cursor stopped responding mid-motion and the process had to be killed.

The cause was the Tailwind CSS language server. Its upstream filetype list includes `markdown`, `html`, every template language and every JavaScript dialect, and its root-marker list ends in `.git` — an upstream fallback for Tailwind v4 projects, which no longer require a `tailwind.config.*` file. Together those mean the server starts for a plain Markdown file and takes the enclosing git repository as its workspace. The home directory is itself a git repository in this environment, so the server was rooted at `$HOME` and sent walking through roughly 12 GB of `.nuget`, `.cache` and `.local`, registering a `didChangeWatchedFiles` watch over the result. That traffic is serviced on Neovim's main loop, so the editor stopped redrawing.

The same fallback misfires in ordinary projects too, just less visibly: any Markdown, HTML or TypeScript file in any git repository started the server, whether or not Tailwind was in use.

## What Changes

- Give the Tailwind server an explicit `root_dir` that accepts only a real Tailwind or PostCSS configuration file, dropping the `.git` fallback.
- Attach nothing when no such file is found, rather than falling back to the buffer's own directory.
- Leave every other server's root determination as `nvim-lspconfig` ships it.

## Capabilities

### Modified Capabilities

- `language-servers`: adds a requirement that a server's workspace is a project that server belongs to, and that a server with no such workspace does not attach.

### New Capabilities

<!-- None. -->

## Impact

- `lua/plugins/lsp.lua` gains one `vim.lsp.config("tailwindcss", ...)` block beside the existing `lua_ls` one.
- Tailwind completion and linting stop appearing in files that merely sit inside a git repository. In a project carrying a Tailwind or PostCSS config they are unchanged.
- A Tailwind v4 project with no configuration file of any kind loses the server until a `postcss.config.*` is added or its directory is named in the marker list. This is the deliberate cost of dropping the fallback.
- No other server is affected: the override names `tailwindcss` alone.
