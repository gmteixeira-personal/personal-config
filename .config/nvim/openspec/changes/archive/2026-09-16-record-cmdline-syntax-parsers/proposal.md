## Why

The floating command line highlights what is typed into it according to what is being typed — a search pattern as a regular expression, a `:!` line as a shell command — and which of those work depends on files that are not in this repository and were not written down anywhere until now. Two of them were missing on this machine for as long as the capability has existed; the editor's health report said so on every run and nothing else did.

They cannot be tracked here: a parser is a compiled object, and its query belongs to a version of a grammar rather than to this configuration. So the only thing the repository can hold is the statement that they are required, which half is which, and how to put them back. Without that, a fresh checkout has a capability that silently renders two of its inputs as plain text, and the person reading the configuration has no way to tell that from how it is meant to be.

## What Changes

- A requirement that the command-line input is highlighted for the kind of input it is, and that where the editor bundles neither the parser nor its query, the configuration records what has to be installed rather than installing a plugin to manage it.
- The requirement states the two halves — a parser alone changes nothing, because the capability asks for the language's highlights query and gives up when there is none — and that the grammar is pinned to the revision the query is written against.
- Absence stays a degradation rather than a fault: a machine without the files renders those inputs unhighlighted and everything else works.

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `message-ui`: added — the command-line input's syntax highlighting, and what the configuration must record about the parsers behind it.

## Impact

- `lua/plugins/noice.lua` — the tree-sitter comment already carries the paths, the two pinned revisions, the build command, the query URL and the editor's ABI range. This change is what makes that comment required rather than incidental.
- No plugin is added, and nothing in the repository changes size: the files it describes live under `~/.local/share/nvim/site/`.
