vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
})

-- lazydev.nvim — deferred until a Lua file is opened
vim.pack.add({
  { src = "https://github.com/folke/lazydev.nvim" },
}, {
  load = function() end,
})

-- Enable some settings globally
vim.lsp.config("*", {
  -- allow for multiline token support
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  },
  -- make .git always be a root marker
  root_markers = { '.git' },
})

-- Load per-server settings from lsp/*.lua
-- Maps: module name (filename) -> LSP server name
local server_configs = {
  go = "gopls",   -- lsp/go.lua  -> gopls settings
  nixd = "nixd",
}
for mod, server in pairs(server_configs) do
  local ok, settings = pcall(require, "lsp." .. mod)
  if ok and settings then
    vim.lsp.config(server, settings)
  end
end

-- enable specific language servers
vim.lsp.enable({
  "nixd",
  "lua_ls",
  "jsonls",
  "html",
  "marksman",
  "gopls",
  "ruff",
  "basedpyright",
  "yamlls",
  "bashls",
  "just",
  "qmlls",
})

-- Only activate lazydev.nvim when editing Lua files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.cmd.packadd("lazydev.nvim")
    require("lazydev").setup()
  end,
})
