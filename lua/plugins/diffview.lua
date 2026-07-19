-- diffview.nvim: Git diff/merge viewer
-- https://github.com/sindrets/diffview.nvim

vim.pack.add({
  { src = "https://github.com/sindrets/diffview.nvim" },
})

require("diffview").setup({
  enhanced_diff_hl = true, -- better highlighting for moved lines
  file_panel = {
    win_config = {
      position = "left",
      width = 35,
    },
  },
})

-- Keybindings
vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<CR>",      { desc = "Open diffview" })
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewClose<CR>",     { desc = "Close diffview" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", { desc = "File history" })
