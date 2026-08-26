-- Animates the cursor between positions, so a large jump is traceable instead of teleporting.
return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy", -- purely decorative, so it must not sit on the startup path
  opts = {}, -- defaults
}
