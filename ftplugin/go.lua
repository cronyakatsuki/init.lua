-- Go-specific settings and keymaps
-- Applied automatically for .go files

-- Settings (Go standard: tabs for indentation, but gofumpt handles formatting)
vim.bo.tabstop    = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 4
vim.bo.expandtab  = false  -- Go uses tabs

-- ── User Commands ──────────────────────────────────────────────────────────

-- GoBuild: build the current package
vim.api.nvim_create_user_command("GoBuild", function()
  vim.cmd("w")  -- save first
  local result = vim.fn.system("go build ./... 2>&1")
  if vim.v.shell_error == 0 then
    vim.notify("Go: build OK", vim.log.levels.INFO)
  else
    vim.notify("Go: build failed\n" .. result, vim.log.levels.ERROR)
    vim.fn.setqflist({ { text = result } }, "r")
    vim.cmd("copen")
  end
end, { desc = "Go: build current package" })

-- GoRun: run the main package
vim.api.nvim_create_user_command("GoRun", function()
  vim.cmd("w")
  vim.cmd("term go run .")
end, { desc = "Go: run main package" })

-- GoTest: run tests in current package
vim.api.nvim_create_user_command("GoTest", function()
  vim.cmd("w")
  local result = vim.fn.system("go test ./... 2>&1")
  if vim.v.shell_error == 0 then
    vim.notify("Go: tests passed", vim.log.levels.INFO)
  else
    vim.notify("Go: tests failed", vim.log.levels.WARN)
    vim.fn.setqflist({}, "r", {
      lines = vim.fn.split(result, "\n"),
      efm = "%f:%l:%c: %m",
    })
    vim.cmd("copen")
  end
end, { desc = "Go: run all tests" })

-- GoTestFunc: run test at cursor
vim.api.nvim_create_user_command("GoTestFunc", function()
  vim.cmd("w")
  local word = vim.fn.expand("<cword>")
  local result = vim.fn.system("go test -run " .. vim.fn.shellescape(word) .. " ./... 2>&1")
  if vim.v.shell_error == 0 then
    vim.notify("Go: test " .. word .. " passed", vim.log.levels.INFO)
  else
    vim.notify("Go: test " .. word .. " failed", vim.log.levels.WARN)
    vim.fn.setqflist({}, "r", {
      lines = vim.fn.split(result, "\n"),
      efm = "%f:%l:%c: %m",
    })
    vim.cmd("copen")
  end
end, { desc = "Go: run test at cursor" })

-- GoCoverage: toggle coverage
vim.api.nvim_create_user_command("GoCoverage", function()
  vim.cmd("w")
  local result = vim.fn.system("go test -coverprofile=" .. vim.fn.tempname() .. " ./... 2>&1")
  if vim.v.shell_error == 0 then
    vim.notify("Go: coverage OK", vim.log.levels.INFO)
  else
    vim.notify("Go: coverage failed\n" .. result, vim.log.levels.ERROR)
  end
end, { desc = "Go: run coverage" })

-- GoAlt: switch between _test.go and .go files
vim.api.nvim_create_user_command("GoAlt", function()
  local buf = vim.fn.expand("%:t")
  local dir = vim.fn.expand("%:p:h")
  local alt
  if buf:match("_test%.go$") then
    alt = buf:gsub("_test%.go$", ".go")
  else
    alt = buf:gsub("%.go$", "_test.go")
  end
  local full = dir .. "/" .. alt
  if vim.fn.filereadable(full) == 1 then
    vim.cmd("e " .. full)
  else
    vim.notify("Go: " .. alt .. " not found", vim.log.levels.WARN)
  end
end, { desc = "Go: switch to alternate file (test/code)" })

-- ── Keymaps ────────────────────────────────────────────────────────────────

vim.keymap.set("n", "<Leader>lf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { buffer = true, desc = "Format Go buffer" })

-- Tests
vim.keymap.set("n", "<Leader>gt", function()
  local test_func = vim.fn.expand("<cword>")
  if test_func:match("^Test") then
    vim.cmd("GoTestFunc")
  else
    vim.cmd("GoTest")
  end
end, { buffer = true, desc = "Go: run test (nearest or package)" })

vim.keymap.set("n", "<Leader>gT", ":GoTestFunc<CR>",      { buffer = true, desc = "Go: run test at cursor" })
vim.keymap.set("n", "<Leader>ga", ":GoAlt<CR>",            { buffer = true, desc = "Go: switch to alternate file" })
vim.keymap.set("n", "<Leader>gc", ":GoCoverage<CR>",      { buffer = true, desc = "Go: toggle coverage" })

-- Build / run
vim.keymap.set("n", "<Leader>gb", ":GoBuild<CR>",         { buffer = true, desc = "Go: build package" })
vim.keymap.set("n", "<Leader>gr", ":GoRun<CR>",            { buffer = true, desc = "Go: run main package" })

-- LSP code actions
vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { buffer = true, desc = "LSP code action" })

-- Open quickfix window (test output)
vim.keymap.set("n", "<Leader>gq", ":copen<CR>",           { buffer = true, desc = "Go: open quickfix (test output)" })
