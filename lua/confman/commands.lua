local render = require('confman.render')

---@class TinyConfmanCommands
local M = {}

---@type function
---adds the plugin commands
---@param module TinyConfmanCore
M.setup = function(module)
    vim.api.nvim_create_user_command('PlgLsAll', function()
        render.list_plugins(module.list_available())
    end, { desc = 'list all plugins' })
    vim.api.nvim_create_user_command('PlgLs', function()
        render.list_plugins(module.list_enabled())
    end, { desc = 'list enabled plugins' })
    vim.api.nvim_create_user_command('PlgEn', module.enable, { desc = 'enable plugin', bang = true })
    vim.api.nvim_create_user_command('PlgDisg', module.disable, { desc = 'disable plugin' })
end

return M
