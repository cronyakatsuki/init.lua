-- which-key.nvim: Keybinding popup help
-- https://github.com/folke/which-key.nvim
-- Replaces mini.clues with a richer popup-window UI.
-- Auto-discovers keymaps from their `desc` attributes.

vim.pack.add({
  { src = "https://github.com/folke/which-key.nvim" },
})

local wk = require("which-key")

wk.setup({
  -- Use a modern popup look
  preset = "modern",

  -- Slightly longer delay so it doesn't pop up on fast typing,
  -- but instant for plugin-registered mappings
  delay = function(ctx)
    return ctx.plugin and 0 or 300
  end,

  -- Built-in plugins replace what mini.clues handled manually
  plugins = {
    marks = true,       -- ' and ` → show marks
    registers = true,   -- " in normal, <C-r> in insert → show registers
    spelling = {
      enabled = true,
      suggestions = 20,
    },
    presets = {
      operators    = true,  -- d, y, c, etc.
      motions      = true,  -- w, b, j, k, etc.
      text_objects = true,  -- iw, ap, etc. after operator
      windows      = true,  -- <C-w> bindings
      nav          = true,  -- misc window nav
      z            = true,  -- folds, spelling
      g            = true,  -- g prefixed bindings
    },
  },
})

-- Define group labels for <leader> prefix keys.
-- Individual mappings with `desc` are auto-discovered.
wk.add({
  { "<leader>f", group = "Find" },
  { "<leader>d", group = "Debug" },
  { "<leader>s", group = "Session" },
  { "<leader>v", group = "Visits" },
  { "<leader>l", group = "LSP" },
  { "<leader>c", group = "Copilot" },
  { "<leader>e", group = "Explorer" },
  { "<leader>o", group = "Orgmode" },
  { "<leader>oi", group = "Insert" },
  { "<leader>ol", group = "Links" },
  { "<leader>oa", group = "Agenda" },
  { "<leader>nd", group = "Roam Dailies" },
})
