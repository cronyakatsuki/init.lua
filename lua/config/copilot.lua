-- Copilot toggle manager
-- Copilot is disabled on startup (no keepassxc password prompt).
-- Enable it manually via :CopilotToggle or <leader>cc.
-- Only the first enable triggers the auth prompt.

local M = {
  --- nil = not yet initialized, true = enabled, false = disabled
  state = nil,
}

-- blink.cmp config object — shared reference, modifying sources.default in place works
-- because blink.cmp reads from this table on every completion request.
local blink_config = require("blink.cmp.config").sources

function M.toggle()
  if M.state == nil then
    -- First-time setup: initializes the Copilot agent (triggers keepassxc auth)
    require("copilot").setup({
      suggestion = { enabled = false },
      panel = { enabled = false },
    })
    M.state = true
    M._add_source()
    vim.notify("Copilot initialized and enabled", vim.log.levels.INFO)
  elseif M.state then
    -- Disable
    require("copilot.command").disable()
    M.state = false
    M._remove_source()
    vim.notify("Copilot disabled", vim.log.levels.INFO)
  else
    -- Re-enable (no auth prompt — setup already done)
    require("copilot.command").enable()
    M.state = true
    M._add_source()
    vim.notify("Copilot enabled", vim.log.levels.INFO)
  end
end

--- Add "copilot" to blink.cmp's default source list (in-place)
function M._add_source()
  if not vim.tbl_contains(blink_config.default, "copilot") then
    table.insert(blink_config.default, "copilot")
  end
end

--- Remove "copilot" from blink.cmp's default source list (in-place)
function M._remove_source()
  for i, src in ipairs(blink_config.default) do
    if src == "copilot" then
      table.remove(blink_config.default, i)
      break
    end
  end
end

-- Register the :CopilotToggle command
vim.api.nvim_create_user_command("CopilotToggle", M.toggle, { desc = "Toggle Copilot on/off" })

return M
