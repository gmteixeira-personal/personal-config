-- Installs and updates the external binaries (language servers, formatters) this config needs,
-- under stdpath("data")/mason/ so nothing lands on the system or the login shell's PATH.
return {
  "mason-org/mason.nvim",
  lazy = false, -- eager: mason prepends mason/bin to the editor's PATH, and the first BufReadPre
  -- can already spawn a formatter or a server. Loading later would leave that first spawn
  -- resolving against the system PATH only.
  opts = {}, -- defaults; PATH = "prepend" is what makes managed binaries resolvable by bare name,
  -- while still letting a system-installed copy win when no managed one exists.
}
