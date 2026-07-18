-- Go LSP: gopls
-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
return {
  settings = {
    gopls = {
      -- Use gofumpt (must be installed separately)
      gofumpt = true,

      -- Enable staticcheck
      staticcheck = true,

      -- Analyses settings
      analyses = {
        unusedparams    = true,
        unusedwrite     = true,
        shadow          = true,
        nilness         = true,
        fieldalignment  = true,
        simplifyrange   = true,
        simplifyslice   = true,
        sortcomments    = true,
        useany          = true,
      },

      -- Code lenses (clickable actions in editor)
      codelenses = {
        gc_details          = true,  -- show garbage collector details
        generate            = true,  -- generate code (e.g. Stringer)
        regenerate_cgo      = true,  -- regenerate cgo definitions
        run_govulncheck     = true,  -- run govulncheck
        test                = true,  -- run tests
        tidy                = true,  -- go mod tidy
        upgrade_dependency  = true,  -- upgrade dependencies
        vendor              = true,  -- go mod vendor
      },

      -- Hover
      linksInHover     = true,
      hoverKind        = "Structured",  -- "SingleLine" | "NoDocumentation" | "Structured" | "SynopsisDocumentation"

      -- Completion
      usePlaceholders  = true,

      -- Diagnostics
      diagnosticsDelay = "500ms",

      -- Semantic tokens
      semanticTokens = true,
    },
  },
}
