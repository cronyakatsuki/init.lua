-- playthrough.nvim helper: list/jump to playthrough files + auto-target for capture.
-- Used by the 'l' capture template target:
--   target = "%(return require('playthrough').capture_target())"
-- and by the <leader>op keymap (list & jump).

local M = {}

local ORG_DIR = vim.fn.expand("~") .. "/org"
M.playthroughs_dir = ORG_DIR .. "/playthroughs"
M.last = nil -- last playthrough file opened/used (for capture auto-target)

local function is_playthrough(path)
  if not path or #path == 0 then
    return false
  end
  local p = vim.fn.fnamemodify(path, ":p")
  local dir = vim.fn.fnamemodify(M.playthroughs_dir, ":p")
  return vim.fn.stridx(p, dir) == 0 -- prefix match
end

-- Current buffer's path if it's a playthrough file, else nil.
M.current_file = function()
  local buf = vim.api.nvim_buf_get_name(0)
  if is_playthrough(buf) then
    return buf
  end
  return nil
end

-- Resolve the capture target for the 'l' template:
--   1. the playthrough file you're currently editing
--   2. the last playthrough picked via <leader>op
--   3. prompt for a file (create it if it doesn't exist)
M.capture_target = function()
  local cur = M.current_file()
  if cur then
    M.last = cur
    return cur
  end
  if M.last and vim.fn.filereadable(M.last) == 1 then
    return M.last
  end
  local name = vim.fn.input("Playthrough file? ")
  if name == nil or #name == 0 then
    name = "Untitled"
  end
  if not name:match("%.org$") then
    name = name .. ".org"
  end
  M.last = M.playthroughs_dir .. "/" .. name
  return M.last
end

-- Telescope picker over all playthrough files; opening one remembers it.
M.list = function(opts)
  opts = opts or {}
  if vim.fn.isdirectory(M.playthroughs_dir) == 0 then
    vim.notify("playthroughs dir missing: " .. M.playthroughs_dir, vim.log.levels.WARN)
    return
  end
  require("telescope.builtin").find_files({
    cwd = M.playthroughs_dir,
    prompt_title = "Playthroughs",
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local state = require("telescope.actions.state")
      local function open()
        local entry = state.get_selected_entry()
        if not entry then
          return
        end
        local path = entry.path or entry.value
        if path then
          path = vim.fn.fnamemodify(path, ":p")
          M.last = path
        end
        actions.close(prompt_bufnr)
        if path and vim.fn.filereadable(path) == 1 then
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        end
      end
      map("i", "<CR>", open)
      map("n", "<CR>", open)
      return true
    end,
  })
end

return M