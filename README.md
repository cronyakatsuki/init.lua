# Neovim Config

A from-scratch Neovim configuration focused on **functionality, performance, and simplicity**.

## Philosophy & Key Decisions

### Plugin Manager: `vim.pack` (built-in) over `lazy.nvim`

**Why:** After migrating to lazy.nvim and comparing startup times, the complexity of a separate plugin manager wasn't worth the ~74ms saved by deferred loading. With `vim.schedule()` for the single heaviest plugin (orgmode), startup is ~82ms — well below human perception. lazyloading .

### Package Management: Nix shells over `mason.nvim`

Language servers, formatters, and linters are provided by Nix shells per project (or global system install). `nvim-lspconfig` auto-detects anything on `$PATH`. No mason.

### `mini.nvim` preference

Wherever mini.nvim provides a feature (cursorword, hipatterns, surround, etc.), it's used over standalone alternatives. Consistent API, single maintainer, lightweight.

### No UI/Looks plugins

Explicitly avoided noice.nvim, lualine.nvim, bufferline.nvim, and similar cosmetic plugins. The focus is on editing efficiency, not eye candy.

---

## Plugin Stack

### Core & Colorscheme
| Plugin | Purpose | Load |
|--------|---------|------|
| [nordic.nvim](https://github.com/AlexvZyl/nordic.nvim) | Colorscheme | Startup |

### Treesitter & Syntax
| Plugin | Purpose | Load |
|--------|---------|------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax parsing, highlighting | Startup |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | Syntax-aware text objects (`vif`, `vaf`, `]m`, `[[`, etc.) | Startup |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | Sticky function/class header while scrolling | Startup |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto-close/rename HTML/JSX tags | Startup |
| [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Rainbow-coloured bracket pairs | Startup |
| [nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) | Correct commentstring in mixed files | Startup |

**Parsers installed:** go, nix, lua, json, html, markdown_inline, python, bash, zsh, just, yaml, javascript, typescript, tsx, css, svelte, vue, c, cpp, rust, java, kotlin

### LSP
| Plugin | Purpose | Load |
|--------|---------|------|
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configuration | Startup |
| [lazydev.nvim](https://github.com/folke/lazydev.nvim) | Lua LSP enhancements | `FileType lua` only |

**Enabled servers:** nixd, lua_ls, jsonls, html, marksman, gopls, ruff, basedpyright, yamlls, bashls, just, qmlls, org

### Completion
| Plugin | Purpose | Load |
|--------|---------|------|
| [blink.cmp](https://github.com/Saghen/blink.cmp) | Completion engine (v2, Rust-backed fuzzy matcher) | Startup |
| [LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine | Startup |
| [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Snippet collection | Startup |
| [copilot.lua](https://github.com/zbirenbaum/copilot.lua) | Copilot LSP backend | Startup (disabled, toggled on demand) |
| [blink-copilot](https://github.com/fang2hou/blink-copilot) | blink.cmp Copilot source | Startup (disabled, toggled on demand) |

**Copilot** is disabled on startup to avoid the keepassxc password prompt. Toggle with `<leader>cc` or `:CopilotToggle`.

### Fuzzy Finding
| Plugin | Purpose | Load |
|--------|---------|------|
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder (replaces mini.pick) | Startup |
| [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | Native fzf sorting (out-of-order matching) | Startup |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | Lua utilities (telescope dependency) | Startup |
| [telescope-orgmode.nvim](https://github.com/nvim-orgmode/telescope-orgmode.nvim) | Orgmode headline/tag/refile/link pickers | Startup |
| [telescope-undo.nvim](https://github.com/debugloop/telescope-undo.nvim) | Visual undo tree browser | Startup |
| [telescope-zoxide](https://github.com/jvgrootveld/telescope-zoxide) | Zoxide directory picker | Startup |

**Why replace mini.pick?** mini.pick lacks out-of-order fuzzy matching (e.g. `src/lua` won't match `lua/src`). telescope-fzf-native provides proper fzf-style matching.

### Editing
| Plugin | Purpose | Load |
|--------|---------|------|
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | Swiss-army knife (all modules below) | Startup |

**mini.nvim modules used:**
- `mini.git` / `mini.diff` — Git gutter signs
- `mini.statusline` — Status line
- `mini.move` — Line/selection moving
- `mini.splitjoin` — Toggle single/multi-line arguments
- `mini.surround` — Surround text objects
- `mini.indentscope` — Indent scope highlighting
- `mini.notify` — In-editor notifications
- `mini.comment` — Comment/uncomment (`gc`, `gcc`)
- `mini.files` — File explorer
- `mini.sessions` — Session management
- `mini.visits` — Visit/file tracking
- `mini.starter` — Startup screen
- `mini.icons` — Icon provider for blink.cmp and telescope
- `mini.hipatterns` — Highlight TODO/FIXME/HACK/NOTE + hex colors
- `mini.cursorword` — Auto-highlight word under cursor

### Formatting & Linting
| Plugin | Purpose | Load |
|--------|---------|------|
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatter (alejandra for nix, gofumpt+goimports for go) | Startup |
| [nvim-lint](https://github.com/mfussenegger/nvim-lint) | Linter (golangci-lint for go) | Startup |

### Debugging
| Plugin | Purpose | Load |
|--------|---------|------|
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol client | Startup |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | DAP UI (scopes, breakpoints, stacks, watches, REPL) | Startup |
| [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) | Go DAP configuration (delve) | Startup |
| [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Inline evaluated expression display | Startup |
| [nvim-nio](https://github.com/nvim-neotest/nvim-nio) | Async library (dap-ui + neotest dependency) | Startup |

**Note:** No Python DAP adapter configured — gap if debugging Python.

### Testing
| Plugin | Purpose | Load |
|--------|---------|------|
| [neotest](https://github.com/nvim-neotest/neotest) | Test runner framework | Startup |
| [neotest-golang](https://github.com/fredrikaverpil/neotest-golang) | Go test adapter (`go test`) | Startup |
| [neotest-python](https://github.com/nvim-neotest/neotest-python) | Python test adapter (pytest) | Startup |
| [neotest-plenary](https://github.com/nvim-neotest/neotest-plenary) | Lua/Neovim plugin test adapter (busted) | Startup |

### Git
| Plugin | Purpose | Load |
|--------|---------|------|
| [diffview.nvim](https://github.com/sindrets/diffview.nvim) | Git diff/merge viewer | Startup |

### Git + mini.git/mini.diff provide gutter signs. diffview adds rich diff browsing.

### Markdown
| Plugin | Purpose | Load |
|--------|---------|------|
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | In-buffer markdown rendering | `FileType markdown` only |
| [markdown.nvim](https://github.com/tadmccorkle/markdown.nvim) | Markdown utilities | `FileType markdown` only |
| [markdown-table-mode.nvim](https://github.com/Kicamon/markdown-table-mode.nvim) | Table editing | `FileType markdown` only |

### Orgmode
| Plugin | Purpose | Load |
|--------|---------|------|
| [nvim-orgmode](https://github.com/nvim-orgmode/orgmode) | Org-mode (agenda, capture, TODOs, notifications) | Startup, setup deferred via `vim.schedule` |
| [org-roam.nvim](https://github.com/chipsenkbeil/org-roam.nvim) | Roam-style notes (dailies, backlinks) | Startup, setup deferred via `vim.schedule` |

**Why deferred?** orgmode's 180-line setup with capture templates, agenda views, and custom commands costs ~23ms at startup. Since you won't enter orgmode in the first second, setup is scheduled to run 200ms after startup, saving that time.

### Keybinding Help
| Plugin | Purpose | Load |
|--------|---------|------|
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding popup help | Startup |

**Why replace mini.clues?** which-key provides a popup window (vs inline hints), auto-discovers keymaps from `desc` attributes, and requires less manual configuration.

### Diagnostics
| Plugin | Purpose | Load |
|--------|---------|------|
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Live diagnostics/quickfix panel | Startup |

---

## Keybindings Reference

### Leader: `<Space>`

| Group | Prefix | Description |
|-------|--------|-------------|
| **Find** | `<leader>f` | Telescope pickers, file/search/git/visits |
| **Debug** | `<leader>d` | DAP breakpoint, continue, step, REPL, UI |
| **Test** | `<leader>t` | Neotest run, file, last, stop, output, summary |
| **Session** | `<leader>s` | MiniSessions create/select |
| **Visits** | `<leader>v` | MiniVisits add/remove labels |
| **LSP** | `<leader>l` | Format buffer |
| **Copilot** | `<leader>c` | Toggle Copilot |
| **Explorer** | `<leader>e` | Toggle mini.files |
| **Orgmode** | `<leader>o` | Agenda, capture, telescope headings/tags/refile/link |
| **Roam** | `<leader>nd` | Org-roam dailies |
| **Git** | `<leader>g` | Diffview open/close/history |
| **Trouble** | `<leader>x` | Diagnostics, quickfix, references, symbols |
| **Undo** | `<leader>u` | Telescope undo tree |
| **Zoxide** | `<leader>z` | Telescope zoxide |

### Text Objects (treesitter)

| Key | Selects |
|-----|---------|
| `vif` / `vaf` | Inner / around function |
| `vic` / `vac` | Inner / around class |
| `vil` / `val` | Inner / around loop |
| `vii` / `vai` | Inner / around conditional |
| `vip` / `vap` | Inner / around parameter |
| `vib` / `vab` | Inner / around block |
| `vir` / `var` | Inner / around return |

### Motion (treesitter)

| Key | Action |
|-----|--------|
| `]m` / `[m` | Next/previous method |
| `[M` / `]M` | End of next/previous method |
| `]]` / `[[]` | Next/previous class |
| `][` / `[]` | End of next/previous class |
| `<leader>sn` / `<leader>sp` | Swap parameter next/previous |

---

## Performance

| Metric | Value |
|--------|-------|
| Startup time | ~82ms |
| Plugins total | 35 |
| Loaded at startup | 33 |
| Deferred (load on demand) | render-markdown, markdown.nvim, markdown-table-mode, lazydev.nvim |
| Deferred setup (via `vim.schedule`) | orgmode, org-roam |

---

## Language Support

| Language | LSP | Formatter | Linter | Test adapter |
|----------|-----|-----------|--------|-------------|
| Go | gopls | gofumpt + goimports | golangci-lint | neotest-golang |
| Python | basedpyright + ruff | ruff | ruff | neotest-python |
| Lua | lua_ls + lazydev.nvim | — | — | neotest-plenary |
| Nix | nixd | alejandra | — | — |
| Bash | bash-language-server | — | — | — |
| Org | org (built-in) | — | — | — |

---

## File Structure

```
~/.config/nvim/
├── init.lua                        # Entry point
├── lazy-lock.json                  # (not used — using vim.pack)
├── nvim-pack-lock.json             # Plugin lockfile
├── README.md
├── lua/
│   ├── config/
│   │   ├── init.lua                # Requires settings, keybindings, autocommands
│   │   ├── settings.lua            # vim.opt options
│   │   ├── keybindings.lua         # Global keymaps
│   │   ├── autocommands.lua        # Autocommands
│   │   └── copilot.lua             # Copilot toggle manager
│   ├── lsp/
│   │   ├── go.lua                  # gopls settings
│   │   └── nixd.lua                # nixd settings
│   └── plugins/
│       ├── init.lua                # Plugin load order
│       ├── colorscheme.lua
│       ├── treesitter.lua          # treesitter + textobjects + context + autotag + rainbow + commentstring
│       ├── lsp.lua                 # lspconfig + lazydev
│       ├── blink.lua               # blink.cmp + LuaSnip + copilot
│       ├── telescope.lua           # telescope + fzf-native + extensions
│       ├── which-key.lua
│       ├── conform.lua
│       ├── lint.lua
│       ├── dap.lua                 # nvim-dap + dap-ui + dap-go + dap-virtual-text
│       ├── neotest.lua             # neotest + adapters
│       ├── trouble.lua             # trouble diagnostics panel
│       ├── diffview.lua            # git diff viewer
│       ├── markdown.lua            # render-markdown + markdown.nvim + table-mode
│       ├── org.lua                 # nvim-orgmode + org-roam
│       └── mini/
│           ├── init.lua            # All mini.nvim modules
│           ├── _files.lua          # mini.files config
│           ├── _highlight.lua      # mini.hipatterns config
│           ├── _pick.lua           # mini.icons only (picker replaced by telescope)
│           ├── _starter.lua        # mini.sessions + mini.visits + mini.starter
│           └── _clues.lua          # Disabled (replaced by which-key)
```
