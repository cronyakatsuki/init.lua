--[[
nvim-treesitter + extras:
  textobjects  – syntax-aware text objects, moves, swaps
  context      – sticky function/class header while scrolling
  autotag      – auto-close / auto-rename HTML/JSX tags
  rainbow      – rainbow-coloured bracket pairs
  context-commentstring – correct commentstring in mixed files
  mini.comment – commenting (paired with context-commentstring)
--]]

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },
  { src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
  { src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },
})

-- ── Core treesitter ──────────────────────────────────────────────
require("nvim-treesitter").setup({})

require("nvim-treesitter").install({
  -- Core languages
  "go", "nix", "lua", "json", "html", "markdown_inline", "python",
  "bash", "zsh", "just", "yaml",
  -- Extra languages for textobjects / context / autotag
  "javascript", "typescript", "tsx", "css", "svelte", "vue",
  "c", "cpp", "rust", "java", "kotlin",
})

-- ── Textobjects: select, move ────────────────────────────────────
require("nvim-treesitter-textobjects").setup({
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      -- Function / method
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      -- Class
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      -- Loop
      ["il"] = "@loop.inner",
      ["al"] = "@loop.outer",
      -- Conditional
      ["ii"] = "@conditional.inner",
      ["ai"] = "@conditional.outer",
      -- Parameter / argument
      ["ip"] = "@parameter.inner",
      ["ap"] = "@parameter.outer",
      -- Block
      ["ab"] = "@block.outer",
      ["ib"] = "@block.inner",
      -- Return statement
      ["ir"] = "@return.inner",
      ["ar"] = "@return.outer",
      -- Comment
      ["ic"] = "@comment.inner",
      ["ac"] = "@comment.outer",
      -- Call expression
      ["aC"] = "@call.outer",
      ["iC"] = "@call.inner",
    },
    selection_modes = {
      ["@parameter.outer"] = "v",     -- charwise
      ["@function.outer"] = "V",      -- linewise
      ["@class.outer"]    = "<c-v>",  -- blockwise
    },
    include_surrounding_whitespace = true,
  },
  move = {
    enable = true,
    set_jumps = true,
    goto_next_start = {
      ["]m"] = "@function.outer",
      ["]]"] = "@class.outer",
    },
    goto_next_end = {
      ["]M"] = "@function.outer",
      ["]["] = "@class.outer",
    },
    goto_previous_start = {
      ["[m"] = "@function.outer",
      ["[["] = "@class.outer",
    },
    goto_previous_end = {
      ["[M"] = "@function.outer",
      ["[]"] = "@class.outer",
    },
  },
})

-- ── Swap: swap parameters / arguments ────────────────────────────
vim.keymap.set({ "n", "x" }, "<leader>sn", function()
  require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
end, { desc = "Swap next parameter" })

vim.keymap.set({ "n", "x" }, "<leader>sp", function()
  require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner")
end, { desc = "Swap previous parameter" })

-- ── Context: sticky header ───────────────────────────────────────
require("treesitter-context").setup({
  enable = true,
  max_lines = 5,
  multiline_threshold = 3,
})

-- ── Auto-tag: close / rename HTML/JSX tags ──────────────────────
require("nvim-ts-autotag").setup({
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = true,
  },
})

-- ── Rainbow delimiters ───────────────────────────────────────────
---@type rainbow_delimiters.config
vim.g.rainbow_delimiters = {
  strategy = {
    [""] = "rainbow-delimiters.strategy.global",
    vim  = "rainbow-delimiters.strategy.local",
  },
  query = {
    [""] = "rainbow-delimiters",
    lua  = "rainbow-blocks",
  },
  priority = {
    [""] = 110,
    lua  = 210,
  },
  highlight = {
    "RainbowDelimiterRed",
    "RainbowDelimiterYellow",
    "RainbowDelimiterBlue",
    "RainbowDelimiterOrange",
    "RainbowDelimiterGreen",
    "RainbowDelimiterViolet",
    "RainbowDelimiterCyan",
  },
}

-- ── Context commentstring (mixed‑file comment support) ───────────
require("ts_context_commentstring").setup({
  enable_autocmd = false, -- we'll trigger via mini.comment integration
})

-- ── Run TSUpdate after nvim-treesitter is installed/updated ──────
vim.api.nvim_create_autocmd("PackChanged", {
  desc = "Handle nvim-treesitter updates",
  group = vim.api.nvim_create_augroup("nvim-treesitter-pack-changed-update-handler", { clear = true }),
  callback = function(event)
    if event.data.kind == "update" and event.data.spec.name == "nvim-treesitter" then
      vim.notify("nvim-treesitter updated, running TSUpdate...", vim.log.levels.INFO)
      ---@diagnostic disable-next-line: param-type-mismatch
      local ok = pcall(vim.cmd, "TSUpdate")
      if ok then
        vim.notify("TSUpdate completed successfully!", vim.log.levels.INFO)
      else
        vim.notify("TSUpdate command not available yet, skipping", vim.log.levels.WARN)
      end
    end
  end,
})
