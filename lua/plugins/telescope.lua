-- telescope.nvim: fuzzy finder (replaces mini.pick + mini.extra)
-- https://github.com/nvim-telescope/telescope.nvim
-- Uses telescope-fzf-native for fast out-of-order fuzzy matching.

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
})

-- Build the fzf-native C extension after install/update
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("telescope-fzf-build", { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == "telescope-fzf-native.nvim"
      and (ev.data.kind == "install" or ev.data.kind == "update") then
      vim.system({ "make" }, { cwd = ev.data.path })
    end
  end,
})

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
-- for custom pickers
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

-- Convert paths from MiniVisits into telescope-compatible entries
local function path_to_entry(path)
  -- path is a string like "/home/user/project/file.lua"
  -- telescope expects entries with a "path" or "filename" field for preview
  return { path = path, filename = vim.fn.fnamemodify(path, ":t") }
end

telescope.setup({
  defaults = {
    -- Vim-like keybindings in both insert and normal mode
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-h>"] = actions.which_key,
        ["<C-c>"] = actions.close,
        ["<Esc>"] = actions.close,
      },
      n = {
        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
        ["q"] = actions.close,
        ["?"] = actions.which_key,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                     -- enable fuzzy matching
      override_generic_sorter = true,   -- use fzf for all text sorting
      override_file_sorter = true,      -- use fzf for file sorting
      case_mode = "smart_case",         -- smart / ignore / respect
    },
  },
})

telescope.load_extension("fzf")

-- ── File / text pickers ──────────────────────────────────────────
vim.keymap.set("n", "<Leader>ff", builtin.find_files,  { desc = "Find files" })
vim.keymap.set("n", "<Leader>fw", builtin.live_grep,   { desc = "Live grep" })

-- ── Help / diagnostics ──────────────────────────────────────────
vim.keymap.set("n", "<Leader>fh", builtin.help_tags,   { desc = "Search help" })
vim.keymap.set("n", "<Leader>fd", builtin.diagnostics, { desc = "Search diagnostics" })

-- ── Git pickers ─────────────────────────────────────────────────
vim.keymap.set("n", "<Leader>fgb", builtin.git_branches, { desc = "Search git branches" })
vim.keymap.set("n", "<Leader>fgc", builtin.git_commits,  { desc = "Search git commits" })
vim.keymap.set("n", "<Leader>fgh", builtin.git_status,   { desc = "Search git changed files" })

-- ── Pattern search (TODO / FIXME / HACK / NOTE) ─────────────────
vim.keymap.set("n", "<Leader>fp", function()
  builtin.grep_string({
    search = [[TODO\|FIXME\|HACK\|NOTE]],
    additional_args = { "--fixed-strings" },
  })
end, { desc = "Search patterns" })

-- ── Visited files (powered by MiniVisits) ───────────────────────
-- Replaces the old `:Pick visit_paths` from mini.extra
vim.keymap.set("n", "<Leader>fv", function()
  local MiniVisits = require("mini.visits")
  local paths = MiniVisits.list_paths()
  pickers.new({}, {
    prompt_title = "Visited files",
    finder = finders.new_table({
      results = vim.tbl_map(path_to_entry, paths),
      entry_maker = function(entry)
        return {
          value = entry.path,
          display = entry.filename,
          ordinal = entry.filename,
          path = entry.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}),
    attach_mappings = function(_, map)
      actions.select_default:replace(function(prompt_bufnr)
        local selection = actions.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)
        if selection then vim.cmd("edit " .. selection.path) end
      end)
      return true
    end,
  }):find()
end, { desc = "Search visited files" })

-- Filtered by "core" label
vim.keymap.set("n", "<Leader>fc", function()
  local MiniVisits = require("mini.visits")
  local paths = MiniVisits.list_paths("", { filter = "core" })
  pickers.new({}, {
    prompt_title = "Visited files (core)",
    finder = finders.new_table({
      results = vim.tbl_map(path_to_entry, paths),
      entry_maker = function(entry)
        return {
          value = entry.path,
          display = entry.filename,
          ordinal = entry.filename,
          path = entry.path,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}),
    attach_mappings = function(_, map)
      actions.select_default:replace(function(prompt_bufnr)
        local selection = actions.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)
        if selection then vim.cmd("edit " .. selection.path) end
      end)
      return true
    end,
  }):find()
end, { desc = "Search visited files with tag 'core'" })
