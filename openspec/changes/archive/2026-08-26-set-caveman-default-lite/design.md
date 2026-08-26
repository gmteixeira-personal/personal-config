## Context

See proposal.md — Why. The plugin resolves its default intensity in a fixed order: the `CAVEMAN_DEFAULT_MODE` environment variable, then a repo-local `.caveman/config.json` or `.caveman.json` found by walking up from the working directory, then the user configuration file, then the built-in `full`. The user file is `$XDG_CONFIG_HOME/caveman/config.json` when that variable is set and `~/.config/caveman/config.json` otherwise; `XDG_CONFIG_HOME` is unset here. The plugin's SessionStart hook writes the resolved level to `.claude/.caveman-active`, and a mid-session `/caveman <level>` updates that flag without touching any configuration file.

## Goals / Non-Goals

**Goals:**

- One declaration that every new session picks up, on this machine and on the next one.
- A location the plugin owns and a reinstall cannot clear.

**Non-Goals:**

- Changing the plugin's shipped default or any of its installed files.
- Per-project intensity. The repo-local config layer exists and stays unused.

## Decisions

**Declare it in the user configuration file rather than in the environment.** `CAVEMAN_DEFAULT_MODE` sits above the file in the resolution order and would work, but it would have to be exported from `.bashrc`, which reaches only shells started from bash and mixes an assistant preference into shell startup. The configuration file is what the plugin reads on its own, whatever launched the session. Alternative considered: a repo-local `.caveman.json` at the home directory. Rejected — the upward walk means it would apply to every project nested under the home directory as if it were that project's own setting, which is not what it is.

**Do not edit the plugin cache.** `.claude/plugins/` is derived state, rebuilt from the declaration in `.claude/settings.json` and untracked by design. An edit there is lost on the next reinstall and invisible to a new environment.

**Track the file.** The repository exists to carry configuration between machines, and this file is configuration with no machine-specific or confidential content. It needs its own allowlist entry because the ignore file denies by default; `.config/lazygit/config.yml` and `.config/gh/config.yml` are already tracked the same way.

## Risks / Trade-offs

- **The plugin could change its configuration schema or resolution order in a later version** → the field would be ignored and sessions would fall back to `full`, which is a visible style change rather than a silent failure; re-reading the plugin's resolver settles it.
- **`lite` is close enough to ordinary prose that the style is easy to forget is active** → that is the point of choosing it, and the level is still shown in the session's activation context.
