-- nvim-dap: Debug Adapter Protocol client
-- nvim-dap-ui: UI for nvim-dap
-- nvim-dap-go: Go-specific DAP configuration (uses delve)

vim.pack.add({
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  { src = "https://github.com/leoluz/nvim-dap-go" },
})

local dap = require("dap")
local dapui = require("dapui")

-- UI setup
dapui.setup({
  layouts = {
    {
      elements = {
        { id = "scopes",      size = 0.33 },
        { id = "breakpoints", size = 0.17 },
        { id = "stacks",      size = 0.17 },
        { id = "watches",     size = 0.33 },
      },
      position = "right",
      size = 60,
    },
    {
      elements = {
        { id = "repl",    size = 0.5 },
        { id = "console", size = 0.5 },
      },
      position = "bottom",
      size = 15,
    },
  },
})

-- Show evaluated expression result inline
require("nvim-dap-virtual-text").setup()

-- Go DAP configuration (requires delve on $PATH)
require("dap-go").setup({
  -- delve on PATH from nix shell
  dap_executable = "dlv",
})

-- Auto-open/close DAP UI on debug events
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Keymaps for debugging
vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<Leader>dc", dap.continue,          { desc = "Continue / start debugger" })
vim.keymap.set("n", "<Leader>do", dap.step_over,          { desc = "Step over" })
vim.keymap.set("n", "<Leader>di", dap.step_into,          { desc = "Step into" })
vim.keymap.set("n", "<Leader>dO", dap.step_out,           { desc = "Step out" })
vim.keymap.set("n", "<Leader>dr", dap.repl.toggle,        { desc = "Toggle REPL" })
vim.keymap.set("n", "<Leader>dl", dap.run_last,           { desc = "Run last debug session" })
vim.keymap.set("n", "<Leader>du", dapui.toggle,           { desc = "Toggle DAP UI" })
