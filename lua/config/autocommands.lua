local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.hl_op({ higroup = 'Visual', timeout = 300 })
  end,
})

-- open file on previous position before quitting
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- create directories if they don't exist
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- treat dash as part of the word in CSS/SCSS (e.g. background-color is one word)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "css", "scss" },
  callback = function()
    vim.opt_local.iskeyword:append("-")
  end,
})

-- Enable tree-sitter highlighting for niri (KDL) and Quickshell (QML) configs
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "kdl", "qml", "qmldir" },
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Validate the current niri config.kdl (and its includes) with the niri binary
vim.api.nvim_create_user_command("NiriValidate", function()
  local path = vim.fn.expand("%:p")
  if path == "" or vim.bo.filetype ~= "kdl" then
    vim.notify("NiriValidate needs a .kdl file open", vim.log.levels.WARN)
    return
  end
  if vim.bo.modified then
    vim.cmd("silent write")
  end
  local res = vim.system({ "niri", "validate", "-c", path }, { text = true }):wait()
  if res.code == 0 then
    vim.notify("niri: config valid", vim.log.levels.INFO)
  else
    vim.notify(
      "niri: config INVALID:\n" .. (res.stderr or res.stdout or ""),
      vim.log.levels.ERROR
    )
  end
end, { desc = "Run niri validate on the current KDL file" })

-- disable autocommenting lines
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})
