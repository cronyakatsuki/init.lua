-- telescope.nvim: fuzzy finder (replaces mini.pick + mini.extra)
-- https://github.com/nvim-telescope/telescope.nvim
-- Uses telescope-fzf-native for fast out-of-order fuzzy matching.

-- Build the fzf-native C extension after install/update
-- NOTE: must be registered BEFORE vim.pack.add() so that "install" events
-- fired during add() (including lockfile installs) are caught.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("telescope-fzf-build", { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == "telescope-fzf-native.nvim"
      and (ev.data.kind == "install" or ev.data.kind == "update") then
      -- Synchronous build: vim.system is async and races load_extension
      -- during the same startup (and fails silently if make itself errors).
      local out = vim.fn.system({ "make", "-C", ev.data.path })
      if vim.v.shell_error ~= 0 then
        vim.notify("telescope-fzf-native build failed:\n" .. out, vim.log.levels.ERROR)
      end
    end
  end,
})

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
  { src = "https://github.com/nvim-orgmode/telescope-orgmode.nvim" },
  { src = "https://github.com/debugloop/telescope-undo.nvim" },
  { src = "https://github.com/jvgrootveld/telescope-zoxide" },
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
    undo = {
      -- telescope-undo default options are fine
    },
    zoxide = {
      prompt_title = "[ Zoxide ]",
      mappings = {
        default = {
          after_action = function(selection)
            print("cd to " .. selection.path)
          end,
        },
        ["<C-s>"] = {
          action = function(selection)
            vim.cmd.edit(selection.path)
          end,
        },
      },
    },
  },
})

-- Load telescope extensions
-- Belt-and-braces: if the artifact is still missing (fresh checkout that
-- slipped past the PackChanged build above), compile it now, synchronously,
-- BEFORE the extension load. This is what makes first-launch self-healing.
local fzf_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt", "telescope-fzf-native.nvim")
if not vim.uv.fs_stat(vim.fs.joinpath(fzf_dir, "build", "libfzf.so")) then
  local out = vim.fn.system({ "make", "-C", fzf_dir })
  if vim.v.shell_error ~= 0 then
    vim.notify("telescope-fzf-native build failed:\n" .. out, vim.log.levels.ERROR)
  end
end
telescope.load_extension("fzf")
telescope.load_extension("undo")
telescope.load_extension("zoxide")

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

-- ── Orgmode telescope pickers ───────────────────────────────────
require("telescope-orgmode").setup({
  adapter = "telescope",
  -- Show headlines from all agenda files
  show_location = true,
  show_tags = true,
  show_todo_state = true,
  show_priority = true,
})

local tom = require("telescope-orgmode")
vim.keymap.set("n", "<leader>oH", tom.search_headings, { desc = "Org search headlines" })
vim.keymap.set("n", "<leader>oT", tom.search_tags,     { desc = "Org search tags" })
vim.keymap.set("n", "<leader>oR", tom.refile_heading,  { desc = "Org refile heading" })
vim.keymap.set("n", "<leader>oL", tom.insert_link,     { desc = "Org insert link" })

-- ── Undo tree ───────────────────────────────────────────────────
vim.keymap.set("n", "<leader>u",  "<cmd>Telescope undo<CR>",  { desc = "Undo tree" })

-- ── Zoxide directory picker ─────────────────────────────────────
vim.keymap.set("n", "<leader>z",  "<cmd>Telescope zoxide list<CR>", { desc = "Zoxide directories" })
