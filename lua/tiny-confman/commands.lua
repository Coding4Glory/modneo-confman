local M = {}

---@param module TinyConfmanModule
M.setup = function(module)
    vim.api.nvim_create_user_command('TinyLsAll', module.list_available, { desc = 'list all plugins' })
    vim.api.nvim_create_user_command('TinyLs', module.list_enabled, { desc = 'list enabled plugins' })
    vim.api.nvim_create_user_command('TinyEnPlug', module.enable, { desc = 'enable plugin', bang = true })
    vim.api.nvim_create_user_command('TinyDisPlug', module.disable, { desc = 'disable plugin' })
end

return M
