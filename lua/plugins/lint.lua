-- nvim-lint: Lightweight linter integration
-- https://github.com/mfussenegger/nvim-lint

vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-lint" },
})

local lint = require("lint")

lint.linters_by_ft = {
  go = { "golangcilint" },
}

-- Auto-lint on save
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
