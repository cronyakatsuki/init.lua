-- trouble.nvim: Live diagnostics / quickfix panel
-- https://github.com/folke/trouble.nvim

vim.pack.add({
  { src = "https://github.com/folke/trouble.nvim" },
})

require("trouble").setup({
  modes = {
    -- Show all LSP diagnostics (errors, warnings, hints)
    -- Entries disappear as you fix them
    diagnostics = {
      mode = "diagnostics",
      filter = {
        severity = vim.diagnostic.severity.HINT,  -- show everything from hints up
      },
      auto_open = false,
      auto_close = true,
      auto_fold = false,
    },
  },
})

-- Keybindings
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",
  { desc = "Toggle diagnostics panel" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
  { desc = "Toggle diagnostics (buffer only)" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>",
  { desc = "Toggle quickfix list" })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>",
  { desc = "Toggle location list" })
vim.keymap.set("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>",
  { desc = "Toggle LSP references" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle<CR>",
  { desc = "Toggle document symbols" })
