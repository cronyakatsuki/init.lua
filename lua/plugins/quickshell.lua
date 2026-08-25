--[[
Quickshell QML support:
  blink.cmp completions for Quickshell types (PanelWindow, Process, Variants, ...)
  qmljs tree-sitter parser registration + 10 Quickshell snippets
  (qmlls itself is configured in plugins/lsp.lua with -E)
--]]

vim.pack.add({
  { src = "https://github.com/cushycush/quickshell-completions.nvim" },
})

require("quickshell-completions").setup({
  lsp = { enable = false }, -- qmlls lives in plugins/lsp.lua (with -E)
  treesitter = { ensure_installed = true },
  snippets = { enable = true },
})

-- Load Quickshell's snippets through LuaSnip's VSCode loader (qs-* prefixes)
require("luasnip.loaders.from_vscode").lazy_load({
  paths = { require("quickshell-completions").get_snippet_path() },
})
