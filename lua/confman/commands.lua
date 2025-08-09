local render = require('confman.render')

---@class TinyConfmanCommands
local M = {}

---@type function
---adds the plugin commands
---@param module TinyConfmanCore
M.setup = function(module)
    vim.api.nvim_create_user_command('ConfmanList', function()
        render.list_plugins(module.list_available(), module.config)
    end, { desc = 'list all plugins' })
    vim.api.nvim_create_user_command('ConfmanInfo', function()
        render.list_plugins(module.list_enabled(), module.config)
    end, { desc = 'list enabled plugins' })
    vim.api.nvim_create_user_command('ConfmanEnable', module.enable, { desc = 'enable plugin', bang = true })
    vim.api.nvim_create_user_command('ConfmanDisable', module.disable, { desc = 'disable plugin' })
end

return M
