---@class TinyConfmanCommands
local M = {}

---@type function
---adds the plugin commands
---@param module TinyConfmanCore
M.setup = function(module)
    vim.api.nvim_create_user_command('PlgLsAll', module.list_available, { desc = 'list all plugins' })
    vim.api.nvim_create_user_command('PlgLs', module.list_enabled, { desc = 'list enabled plugins' })
    vim.api.nvim_create_user_command('PlgEn', module.enable, { desc = 'enable plugin', bang = true })
    vim.api.nvim_create_user_command('PlgDisg', module.disable, { desc = 'disable plugin' })
end

return M
