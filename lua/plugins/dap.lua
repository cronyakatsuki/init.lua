-- nvim-dap: Debug Adapter Protocol client
-- nvim-dap-virtual-text: inline variable/eval values while stopped
-- nvim-dap-go: Go-specific DAP configuration (uses delve)

vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  { src = "https://github.com/leoluz/nvim-dap-go" },
})

local dap = require("dap")

-- Breakpoint/heuristic signs + eval result virtual text
require("nvim-dap-virtual-text").setup()

-- Go DAP configuration (requires delve on $PATH)
require("dap-go").setup({
  -- delve on PATH from nix shell
  dap_executable = "dlv",
})

-- Keymaps for debugging
vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<Leader>dc", dap.continue,          { desc = "Continue / start debugger" })
vim.keymap.set("n", "<Leader>do", dap.step_over,          { desc = "Step over" })
vim.keymap.set("n", "<Leader>di", dap.step_into,          { desc = "Step into" })
vim.keymap.set("n", "<Leader>dO", dap.step_out,           { desc = "Step out" })
vim.keymap.set("n", "<Leader>dr", dap.repl.toggle,        { desc = "Toggle REPL" })
vim.keymap.set("n", "<Leader>dl", dap.run_last,           { desc = "Run last debug session" })
