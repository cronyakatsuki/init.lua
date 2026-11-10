vim.pack.add({
  { src = "https://github.com/MagicDuck/grug-far.nvim" },
})

require('grug-far').setup()

vim.keymap.set("n", "<Leader>fr", ":GrugFar<CR>", { desc = "Search and replace with grug far" })
