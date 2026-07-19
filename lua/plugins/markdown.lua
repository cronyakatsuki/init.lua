vim.pack.add({
  { src = "https://github.com/tadmccorkle/markdown.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/Kicamon/markdown-table-mode.nvim" },
}, {
  -- Don't auto-load at startup — :packadd will be called on FileType markdown
  load = function() end,
})

-- Only activate markdown plugins when opening a .md file
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.cmd.packadd("markdown.nvim")
    vim.cmd.packadd("render-markdown.nvim")
    vim.cmd.packadd("markdown-table-mode.nvim")
    require("render-markdown").setup({
      completions = { lsp = { enabled = true } },
    })
    require("markdown").setup()
    require("markdown-table-mode").setup()
  end,
})
