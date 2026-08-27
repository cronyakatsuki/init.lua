-- playthrough keymaps: <leader>op = list & jump to a playthrough file.
-- Session logging is the org-capture 'l' template (see plugins/org.lua):
-- it auto-targets the playthrough you're in, or the last one picked here.
local pt = require("playthrough")

vim.keymap.set("n", "<leader>op", function()
  pt.list()
end, { desc = "Playthroughs: list & jump" })