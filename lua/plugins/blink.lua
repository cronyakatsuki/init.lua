-- blink.cmp: Performant, batteries-included completion plugin
-- https://github.com/Saghen/blink.cmp

vim.pack.add({
  { src = "https://github.com/saghen/blink.lib" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/zbirenbaum/copilot.lua" },
  { src = "https://github.com/fang2hou/blink-copilot" },
  { src = "https://github.com/saghen/blink.cmp" },
})

-- Minimal LuaSnip setup (no jump mappings — blink.cmp handles those via snippet_forward/backward)
local ls = require("luasnip")
ls.setup({})

-- Load friendly-snippets (provides snippets for all major languages)
require("luasnip.loaders.from_vscode").lazy_load()


-- Build/download the Rust fuzzy matcher (only needed on first install/update)
-- Uses build() since there are no tagged v2 releases yet for download().
-- When v2 gets its first release, switch to cmp.download():pwait().
local cmp = require("blink.cmp")
cmp.build():pwait()

-- Configure blink.cmp
cmp.setup({
  -- Use LuaSnip as the snippet engine
  snippets = { preset = "luasnip" },

  -- Default keymap preset:
  --   <C-space>  open menu / toggle docs
  --   <C-n> / <C-p>  select next/prev
  --   <C-y>  accept
  --   <C-e>  hide
  --   <Tab> / <S-Tab>  snippet forward/backward
  --   <C-k>  toggle signature help
  keymap = { preset = "default" },

  -- Completion sources
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      copilot = {
        name = "copilot",
        module = "blink-copilot",
        score_offset = 100,
        async = true,
      },
    },
  },

  -- Completion behavior
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    ghost_text = { enabled = true },

    -- Use mini.icons for kind icons in the completion menu
    menu = {
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
        components = {
          kind_icon = {
            text = function(ctx)
              local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
              return kind_icon or ctx.kind_icon
            end,
            highlight = function(ctx)
              local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
              return hl or ctx.kind_hl
            end,
          },
          kind = {
            highlight = function(ctx)
              local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
              return hl or ctx.kind_hl
            end,
          },
        },
      },
    },
  },

  -- Enable experimental signature help
  signature = { enabled = true },
})
