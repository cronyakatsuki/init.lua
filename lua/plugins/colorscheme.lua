vim.pack.add { { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } }
vim.o.background = "dark"

require("catppuccin").setup({
    term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    },
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
        virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
            ok = { "italic" },
        },
        underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
            ok = { "underline" },
        },
        inlay_hints = {
            background = true,
        },
    },
    auto_integrations = true,
})

vim.cmd.colorscheme "catppuccin-nvim"
