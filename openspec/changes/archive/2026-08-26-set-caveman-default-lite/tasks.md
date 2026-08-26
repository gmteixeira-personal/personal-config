## 1. Configuration

- [x] 1.1 Create `~/.config/caveman/config.json` declaring `"defaultMode": "lite"`
- [x] 1.2 Confirm the plugin's resolver returns `lite` for the home directory

## 2. Tracking

- [x] 2.1 Add a `!/.config/caveman/config.json` allowlist entry to `.gitignore`, beside the existing `.config` entries
- [x] 2.2 Confirm `git check-ignore -v .config/caveman/config.json` attributes the path to that entry and `git status` lists the file as untracked
- [x] 2.3 Confirm no path under `.claude/plugins/` became trackable as a side effect
