## Context

See proposal.md — Why. The mechanics that shape the approach:

- `nvim-lspconfig`'s `lsp/tailwindcss.lua` sets `workspace_required = true`. A server declared that way is started only when its `root_dir` resolves; there is no rootless attach to fall back on.
- Its `root_dir` is a function, not a marker list, and it ends with `on_dir(vim.fs.dirname(vim.fs.find(root_files, ...)[1]))`. `vim.fs.dirname(nil)` is `nil`, and calling `on_dir(nil)` is how lspconfig spells "use the buffer's own directory" — so the upstream function never declines to attach.
- `vim.lsp.config(<name>, ...)` merges into the shipped configuration rather than replacing it, so overriding `root_dir` alone leaves the filetype list, capabilities and settings intact.

## Goals / Non-Goals

**Goals:**

- The server attaches where Tailwind is actually in use and nowhere else.
- The editor never takes `$HOME` — or any other tree that is a repository by accident — as a language-server workspace.

**Non-Goals:**

- Removing `tailwindcss` from the installed server set. The problem is where it attaches, not that it exists.
- Trimming the server's filetype list. Tailwind classes genuinely appear in Markdown and in every template language listed; the list is not the defect.
- A general rule applied to every server. No other configured server carries the `.git`-as-last-resort marker in a form that reaches outside a project.

## Decisions

**Override `root_dir` rather than `filetypes`.** Dropping `markdown` from the filetype list would have fixed the reported freeze and left the same bug behind every other listed filetype — an `.html` or `.ts` file in a non-Tailwind repository roots the server exactly as the Markdown file did. Alternative considered: narrowing the filetype list to `html`, `css` and the JS dialects. Rejected — it treats the symptom, loses Tailwind support in templates where it is wanted, and still roots at `$HOME` for a `.ts` file opened there.

**Accept only `tailwind.config.*` and `postcss.config.*`, and drop `.git`.** These are the markers that mean "Tailwind is configured here". `.git` means "this is a repository", which is a different claim and the one that produced the failure. The extension set is `js`, `cjs`, `mjs`, `ts`, matching upstream. Upstream's Django paths (`theme/static_src/…`) and its `package.json`/`mix.lock`/`Gemfile.lock` field probes are dropped with it: each is a further way to root without a Tailwind config present, and none applies to work done here. Alternative considered: keeping `.git` but refusing it when the directory it names is `$HOME`. Rejected — it fixes one directory and leaves every other accidental repository, and it encodes a machine's layout into a server configuration.

**Decline by not calling `on_dir`.** `on_dir` is the callback that supplies the root; not calling it is how a `root_dir` function says there is no workspace, and `workspace_required = true` then means no server is started. Passing `nil` would instead select the buffer's directory, which for `~/README.md` is `$HOME` — the original failure, one level down.

**Build the marker list in a loop rather than writing sixteen literals.** Two bases crossed with four extensions. The loop states the rule; a flat list states the result and drifts when an extension is added.

## Risks / Trade-offs

- **A Tailwind v4 project with no configuration file at all gets no server** → v4 makes `tailwind.config.*` optional, so such projects exist. The recovery is a `postcss.config.js`, which such a project usually has anyway, or naming the directory in the marker list. Accepted as the direct cost of dropping the fallback.
- **A monorepo whose Tailwind config sits above the buffer** → `vim.fs.find` searches upward from the file, so a config at the repository root is found from any depth beneath it. A config in a sibling package is not, which matches where Tailwind actually applies.
- **Upstream changes its root logic** → the override replaces `root_dir` wholesale, so an upstream improvement to it is not picked up. The block is short and self-contained; re-reading it against upstream is a small task when `nvim-lspconfig` is updated.
- **The failure is silent when it happens** → a project that should have the server and does not gives no error, only absent completion. `:checkhealth lsp` and `:LspInfo` both report the server as not attached, which is where this is diagnosed.
