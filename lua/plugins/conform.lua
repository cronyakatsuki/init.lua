vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
})

require("conform").setup({
  formatters_by_ft = {
    nix  = { "alejandra" },
    go   = { "gofumpt", "goimports" },
    toml = { "taplo" },
    qml  = { "qmlformat" },
  },

  formatters = {
    qmlformat = {
      -- Qt's standalone QML formatter (ships with qt6-declarative, not
      -- symlinked into /usr/bin). qmlls's built-in formatter ignores all
      -- formatting options (QTBUG-119971, hardcodes 4 spaces), so route
      -- QML formatting here instead.
      command = "/usr/lib/qt6/bin/qmlformat",
      args = { "-w", "2", "-i", "$FILENAME" }, -- 2-space indent; in-place: conform reads the result back from the temp file (qmlformat can't read stdin)
      stdin = false,
    },
  },
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

vim.keymap.set("n", "<Leader>lf", ":Format<CR>", { desc = "Format buffer with available lsp" })
