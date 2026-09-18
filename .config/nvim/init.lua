-- Entrypoint. Load order is the only thing this file decides.
require("config.options") -- first: leader must exist before any plugin spec is evaluated
require("config.keymaps") -- general mappings, no plugin involved
require("config.file-explorer") -- must precede the plugin manager: it suppresses netrw, and Neovim
-- sources its built-in plugins only once this file has returned
require("config.lazy") -- plugin manager, which imports lua/plugins/
