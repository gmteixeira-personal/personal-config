Paths are relative to the Neovim configuration root (`~/.config/nvim`), which is this OpenSpec workspace's root. Run the verification commands from there.

## 1. Gather the material

- [x] 1.1 Enumerate every plugin the configuration loads with `ls lua/plugins/*.lua lua/plugins/*/*.lua` and record, for each, the upstream plugin name and the job it does; verify the count matches `ls lua/plugins/*.lua lua/plugins/*/*.lua | wc -l` so the plugin section can later be checked against it
- [x] 1.2 Enumerate every general mapping from `lua/config/keymaps.lua`, capturing for each the key, its modes, and the `desc` string already attached to it; verify with `grep -cE '^\s*(map|vim\.keymap\.set)' lua/config/keymaps.lua` and confirm the recorded count matches
- [x] 1.3 Enumerate every plugin-provided mapping with `grep -rn "keys = \|keymap.set" lua/plugins/`, recording the key, its effect, and the plugin file that declares it, so each can be attributed in the keymap tables
- [x] 1.4 Read `lua/config/options.lua` and record the conventions that are observable to a user — display, indentation, wrapping, search, persistence, split direction, clipboard — as behaviour statements rather than as option names, per the spec requirement that the README not be an option dump
- [x] 1.5 Read `init.lua` and `lua/config/lazy.lua` and record the load order and which parts of it are load-bearing; cross-check against `openspec/specs/config-structure/spec.md` and `openspec/specs/plugin-management/spec.md` so the README's account agrees with the specs
- [x] 1.6 List the capability specs with `ls openspec/specs/` and map each plugin group and convention onto the spec that governs it, so the delegation section names a real directory and the summaries do not contradict it

## 2. Write the document

- [x] 2.1 Create `README.md` at the configuration root with the section order fixed in design.md — what this is and how to run it, layout and load order, editor conventions, keymaps, plugins, where the detail lives — and a table of contents; verify with `ls README.md` that the file exists and with `grep -c '^## ' README.md` that every planned top-level section is present
- [x] 2.2 Write the opening section: identify the configuration and the editor, state what to run to reach a working editor, state that the plugin manager and the language servers and formatters are acquired without a manual step, and name any dependency that must already be present on the machine and is not self-provisioned, saying what fails without it; verify by reading it as someone with a fresh clone and confirming no instruction is given for a component the configuration installs itself
- [x] 2.3 Write the layout and load order section: a table of `init.lua`, `lua/config/`, `lua/plugins/`, `lua/plugins/themes/` and `lazy-lock.json` with what belongs in each, the order the modules load, and which ordering constraints are load-bearing and what depends on each; verify every path it names exists with `for p in $(grep -oE '(init\.lua|lua/[a-z/]*|lazy-lock\.json)' README.md | sort -u); do test -e "$p" || echo "MISSING $p"; done` printing nothing
- [x] 2.4 In that same section, state where a new plugin file goes and whether anything else must be edited for it to take effect, including that a new subdirectory must be named in the plugin manager's configuration to be imported at all; verify the statement against `openspec/specs/plugin-management/spec.md` — "Introducing a new subdirectory"
- [x] 2.5 Write the editor conventions section from the material gathered in 1.4, in terms of what the user observes, and give the reason for each convention that overrides a Neovim default in a way a reader could mistake for a malfunction; verify by grepping the section for bare `vim.opt` assignments with `grep -c 'vim\.opt' README.md` returning `0`

## 3. Write the keymap section

- [x] 3.1 State the leader key explicitly before the first table that uses it; verify with `grep -n 'leader' README.md` that the statement appears above the first `<leader>` row
- [x] 3.2 Write one table per prefix family — the deliberately unprefixed overrides, the window-focus and window-resize chords, `<leader>w`, `<leader>b`, `<leader>q`, and the plugin-provided keys — each row giving the key, its effect, and its modes where not obvious; verify every mapping recorded in 1.2 and 1.3 appears by checking each key from those lists against `grep -F '<key>' README.md`
- [x] 3.3 Precede the table of any family that displaces a built-in with a short paragraph saying what it displaces and what the reader gets instead — `H` and `L` in particular, which take over the screen-top and screen-bottom motions; verify against `openspec/specs/editor-keymaps/spec.md` that the description of what was given up matches the spec
- [x] 3.4 Attribute each plugin-provided key to the plugin that declares it, in the row itself; verify by picking three plugin keys from 1.3 at random and confirming the README names the same plugin the declaring file does
- [x] 3.5 Verify the tables carry no key the configuration does not bind, by checking each key in the README's tables against `grep -rn` over `lua/config/keymaps.lua` and `lua/plugins/`

## 4. Write the plugin section

- [x] 4.1 Write the plugin section grouped by job — language support, completion and formatting, git, navigation, editing, interface, sessions and themes — with each plugin named and its purpose stated in a sentence; verify every file from 1.1 is accounted for by checking each plugin's upstream name against `grep -F` over `README.md`
- [x] 4.2 Where several plugins cover related ground — the three git tools in particular — state the boundary that decides which one applies, not just what each is; verify by reading the git group and confirming a reader can tell from it which tool answers a hunk-level, a repository-level, and a revision-difference question
- [x] 4.3 Verify no plugin appears in the README that the configuration does not load, by taking each plugin name from the README and confirming a matching file exists under `lua/plugins/`

## 5. Write the delegation section and check the cut

- [x] 5.1 Write the closing section naming `openspec/specs/` as the authoritative source for per-capability detail, stating that the README works at orientation depth, and stating that on a disagreement the spec governs and the README is what changes; verify with `grep -n 'openspec/specs' README.md` that the directory is named
- [x] 5.2 Verify the README reproduces no specification scenario, with `grep -cE '^\s*-\s+\*\*(WHEN|THEN|AND)\*\*' README.md` returning `0` and `grep -c '#### Scenario' README.md` returning `0`
- [x] 5.3 Verify the README contains none of the enclosing repository's own setup material — no bootstrap, staging, or commit-guard procedure — with `grep -niE 'core\.hooksPath|git init|git remote add|allowlist|denylist|block 3|block 4' README.md` printing nothing
- [x] 5.4 Verify the README is intelligible from this directory alone: read it through and confirm it defers no explanation of the Neovim configuration to a document outside `~/.config/nvim`, and that it names no path outside this directory as required reading

## 6. Verify the whole document against the spec

- [x] 6.1 Read `openspec/changes/add-readme/specs/documentation/spec.md` and walk each scenario against the finished README, confirming each one holds; treat any that does not as a defect in the README rather than in the spec
- [x] 6.2 Verify the README renders as plain markdown with no build step and no external asset, by opening it in Neovim and confirming it is legible as written and references no generated or fetched content
- [x] 6.3 Verify the change touched documentation only, with `git status --short` showing exactly `README.md` and the files under `openspec/changes/add-readme/` as changed, and nothing under `lua/`, `init.lua`, or `lazy-lock.json`
- [x] 6.4 Verify the README is tracked rather than ignored, with `git check-ignore -v README.md` printing nothing and `git status --short README.md` showing it as a new file
- [x] 6.5 Run `openspec validate add-readme --strict` and confirm it reports the change valid
