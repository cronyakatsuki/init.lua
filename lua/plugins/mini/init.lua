vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.nvim" },
})

-- git related stuff
require("mini.git").setup()
require("mini.diff").setup()

-- setup statusline
require("mini.statusline").setup()

-- move lines
require("mini.move").setup()

-- easy split args
require("mini.splitjoin").setup()

-- surround actions
require("mini.surround").setup()

-- amazing fast indent scope highlight plugin
require("mini.indentscope").setup()

-- nice simple notifications inside neovim
require("mini.notify").setup()

require("plugins.mini.files")
require("plugins.mini.highlight")
require("plugins.mini.pick")
require("plugins.mini.completion")
require("plugins.mini.clues")
require("plugins.mini.starter")
