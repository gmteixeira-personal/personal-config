## Context

See proposal.md — Why. What this section adds is the evidence, because the whole change turns on one question the README currently answers wrong: which of the sixteen binaries mason installs can actually run on a machine that has nothing but Neovim and git.

The answer is on disk. Every mason package records how it was installed, and the shape of its directory says what it needs:

| Managed tool | Installed as | Needs on the system |
|---|---|---|
| `vtsls`, `bash-language-server`, `json-lsp`, `yaml-language-server`, `css-lsp`, `html-lsp`, `tailwindcss-language-server`, `fish-lsp`, `prettier`, `prettierd` | npm package (`node_modules/`) | Node.js |
| `basedpyright` | pip package in a virtualenv (`venv/`) | Python 3 with `venv` |
| `roslyn-language-server` | NuGet payload | a .NET SDK |
| `lua-language-server`, `stylua`, `shfmt`, `ruff` | prebuilt binary | nothing |

Ten of sixteen need Node. mason installs all sixteen either way — the install succeeds, the binary lands in `stdpath("data")/mason/bin/`, and the failure surfaces later as a server that never attaches or a formatter that leaves the buffer untouched on write. That gap between "installed" and "runnable" is the thing the README does not currently express, and it is why simply appending rows to the existing table is not enough.

Three further prerequisites are outside mason's tool list entirely:

- **`curl` and an archive extractor.** mason fetches over the network and unpacks what it fetches. Without them nothing installs at all, so this is the one prerequisite whose absence costs every managed tool at once.
- **`ripgrep`.** `lua/plugins/telescope.lua` marks it at the `<leader>fg` binding: live grep has no fallback and simply finds nothing.
- **`fish`.** `lua/plugins/conform.lua` formats fish with `fish_indent`, noting it "ships inside fish itself, so there is no mason package for it and none is declared". `fish_lsp` needs the shell too.

The constraint the rewrite works under is the `documentation` capability's own: the README is orientation, it stands alone within this directory, and it does not restate specs. So this is a rewrite of one section, not a new document.

## Goals / Non-Goals

**Goals:**

- A reader can tell, before starting Neovim, whether their machine will produce a working editor — and for which languages.
- A reader who already has a broken capability can find the missing prerequisite from the symptom alone, without knowing that mason, npm, or a virtualenv exist.
- The prerequisite set is derived from what the configuration declares, so a future change that adds a tool has an obvious place to record its runtime.

**Non-Goals:**

- Install commands per operating system. The README names what must be present; how a given distribution supplies it is not this document's business and would rot immediately.
- Version floors for the runtimes. Only Neovim's floor is load-bearing here — the rest track their tools' own requirements, and stating a number this configuration does not enforce invents a constraint.
- A bootstrap or doctor script. The configuration deliberately has no install script, and adding one would contradict `tool-management`.
- Changing what is installed. No plugin, server, or formatter is added or dropped.

## Decisions

**Group by consequence, not by language.** The candidate arrangement was one row per language — C#, Python, web, shell — which reads well for a reader choosing what to set up and badly for the reader who actually needs this section: the one whose editor is already misbehaving. Grouping by what the absence costs gives three groups that a symptom maps onto directly:

1. **The editor will not start, or nothing installs.** Neovim 0.11+, `git`, `curl` plus an extractor.
2. **A language loses its server or its formatter.** Node.js, Python 3, a .NET SDK, `fish`.
3. **A capability degrades but the editor is fine.** `ripgrep`, a Nerd Font.

The languages are still visible — group 2 names which ones each runtime carries — so the "what do I need for C#?" reading survives, while the diagnostic reading is the one the structure serves.

**State runtimes as prerequisites of capabilities, not of mason packages.** The reader hitting this has an unformatted TypeScript buffer, not a thought about npm. So the entry reads as what is lost — the web and shell servers, and prettier — with the npm mechanism as the explanation rather than the heading. This also keeps the README honest about the boundary `tool-management` draws: the configuration provisions binaries into its own data directory and provisions nothing onto the system.

**Narrow the self-provisioning claim rather than drop it.** The opening still says the configuration installs its plugins and its tools without an install script, because that is true and it is the thing that distinguishes this configuration. What changes is the sentence that currently implies the tool install is sufficient — "Every other language works without anything installed by hand" is the specific line that is false, and it goes.

**Name `:checkhealth` as the check.** `:checkhealth mason` reports the missing runtimes and fetch tools by name, and `:checkhealth telescope` reports ripgrep. Naming them makes the list verifiable on the reader's machine, and keeps the README from having to grow a diagnostic section of its own. Considered and rejected: writing a shell one-liner into the README that probes each binary — it duplicates a check the editor already ships, and it is the kind of thing that drifts from the list above it.

**Mark `fd` as unneeded and say so once.** Telescope's file picker prefers `fd`, then falls back to `rg`, which this configuration already requires. Listing `fd` as optional would put a row in the table that buys the reader nothing. It is mentioned only where a reader might otherwise wonder, if at all.

**Leave the WSL clipboard bridge out of the table.** `clip.exe` and `powershell.exe` are present on any WSL install by construction, and `lua/config/options.lua` already only reaches for them when Neovim found no provider of its own. It is not a prerequisite a reader can fail to satisfy, and the Editor conventions section already describes the behaviour.

## Risks / Trade-offs

**The list goes stale when a tool is added.** → The `documentation` capability already requires a change that alters what is needed to reach a working editor to update the README in the same change; the modified requirement makes the runtime behind a new tool part of that obligation explicitly. The delta spec's derivation scenario is what an audit checks against.

**The section gets long enough that nobody reads it.** → Three short groups with one line of consequence each, still a table, in the same place the current one sits. The per-tool detail that would inflate it belongs to the plugin list, which already carries it.

**Grouping by consequence splits a language's needs across groups.** C# needs the .NET SDK (group 2) and nothing else; TypeScript needs Node (group 2). In practice only the Nerd Font and ripgrep sit outside group 2, so the split is shallow — and naming the affected languages inside each row keeps a language's requirements findable by search.

**Claiming a consequence that is wrong is worse than claiming none.** A reader who is told the editor will not start, and finds it starts, stops trusting the table. → Every consequence stated comes from the configuration's own code path — the bootstrap's exit on a failed clone, conform's silent skip of an unavailable formatter, telescope's empty result — not from a guess at what would probably happen.
