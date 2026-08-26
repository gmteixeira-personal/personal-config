-- Entrypoint. Load order is the only thing this file decides.
require("config.options") -- first: leader must exist before any plugin spec is evaluated
require("config.keymaps") -- general mappings, no plugin involved
require("config.lazy") -- plugin manager, which imports lua/plugins/
