-- QML Language Server settings
-- CachyOS/Arch ships the binary as `qmlls6`, not `qmlls`
-- https://doc.qt.io/qt-6/qtqml-tooling-qmlls.html

-- Quickshell types resolve automatically: they're installed with
-- *.qmltypes under /usr/lib/qt6/qml/Quickshell, which is in qmlls's
-- default import path. `import Quickshell`, `.Io`, `.Hyprland` etc.
-- get completion without extra flags.

return {
  cmd = { 'qmlls6' },
  filetypes = { 'qml', 'qmljs' },
  -- shell.qml/qmldir root markers let it attach to a quickshell
  -- config folder even before it's git-init'ed
  root_markers = { '.git', 'shell.qml', 'qmldir' },

  -- qmlls's formatter hardcodes 4-space indentation and ignores all LSP
  -- formatting options (QTBUG-119971), so take its formatting capability
  -- away; QML formatting goes through conform's qmlformat instead.
  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
