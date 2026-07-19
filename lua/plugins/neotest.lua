-- neotest: Test runner framework
-- https://github.com/nvim-neotest/neotest

vim.pack.add({
  { src = "https://github.com/nvim-neotest/neotest" },
  { src = "https://github.com/fredrikaverpil/neotest-golang" },
  { src = "https://github.com/nvim-neotest/neotest-python" },
  { src = "https://github.com/nvim-neotest/neotest-plenary" },
})

-- nvim-nio is already installed as a dependency of nvim-dap-ui

require("neotest").setup({
  adapters = {
    require("neotest-golang"),
    require("neotest-python")({
      runner = "pytest",
    }),
    require("neotest-plenary"),
  },
  -- Show pass/fail status icons in the sign column
  signs = {
    passed = "✓",
    failed = "✗",
    skipped = "→",
  },
  -- Enable inline diagnostic messages for failed assertions
  diagnostic = {
    enabled = true,
  },
})

-- Keybindings
vim.keymap.set("n", "<leader>tn", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })

vim.keymap.set("n", "<leader>tl", function()
  require("neotest").run.run_last()
end, { desc = "Run last test" })

vim.keymap.set("n", "<leader>ts", function()
  require("neotest").run.stop()
end, { desc = "Stop test" })

vim.keymap.set("n", "<leader>to", function()
  require("neotest").output.open()
end, { desc = "Toggle test output" })

vim.keymap.set("n", "<leader>tS", function()
  require("neotest").summary.toggle()
end, { desc = "Toggle test summary" })
