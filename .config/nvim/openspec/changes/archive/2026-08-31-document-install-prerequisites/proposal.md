## Why

The README claims the configuration is self-provisioning and names three prerequisites — Neovim 0.11+, `git`, and a Nerd Font — plus a .NET SDK for C#. That list is incomplete. Ten of the sixteen tools mason installs are npm packages that need Node.js on the system, one is a pip package that needs Python 3, `fish_indent` ships inside fish itself, mason needs a downloader and an archive extractor to fetch anything at all, and telescope's live grep needs ripgrep. None of those are installed by starting Neovim, and each one fails in a different place — a formatter that silently does nothing on write, a picker that reports no results, a language server that never attaches — long after the launch that was supposed to provision it.

A reader who follows the README today reaches a working editor only if their machine already happened to carry those runtimes.

## What Changes

- Replace the README's three-row Requirements table with a complete account of what must be present beforehand, split by what the absence actually costs: what blocks startup, what a runtime's absence removes, and what is optional.
- Name Node.js as the prerequisite behind ten managed tools (`vtsls`, `bashls`, `jsonls`, `yamlls`, `cssls`, `html`, `tailwindcss`, `fish_lsp`, `prettier`, `prettierd`) and Python 3 as the prerequisite behind `basedpyright`, rather than leaving them implied by the plugin list.
- Name mason's own fetch prerequisites — `curl` and an extractor for archives — as the dependency whose absence stops every managed tool at once.
- Name `ripgrep` for telescope's live grep, `fish` for `fish_indent` and the fish server, and keep the .NET SDK for Roslyn, promoted out of prose into the same table as everything else.
- State per prerequisite what is lost without it, so a reader diagnosing a symptom can work backwards to the missing runtime.
- Keep the self-provisioning claim, narrowed to what is true: the configuration installs plugins and tool *binaries*, not the runtimes those binaries execute on.
- Point at `:checkhealth` as the in-editor check that reports which of these are missing, so the list is verifiable rather than only readable.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `documentation`: the requirement covering what the configuration costs to run currently obliges the README to name external prerequisites and say what fails without each. It is strengthened to oblige a *complete* account — including runtimes needed by tools the configuration installs for itself — grouped by consequence, and to bound the self-provisioning claim so that installing a binary is not presented as supplying the runtime it needs.

## Impact

- `README.md` — the Requirements section is rewritten; the surrounding claims about self-provisioning are narrowed to match.
- `openspec/specs/documentation/spec.md` — one requirement modified.
- No Lua changes. No plugin, keymap, option, or file-layout change; nothing about the configuration's behaviour moves.
