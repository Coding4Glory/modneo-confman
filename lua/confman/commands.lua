--[[
Part of confman.nvim
Copyright (C) 2025  Markus Hergenröder

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
--]]

local render = require('confman.ui.render').init()

---@class TinyConfmanCommands
local M = {}

---@type function
---adds the plugin commands
---@param module ConfmanCore
M.setup = function(module)
    vim.api.nvim_create_user_command('ConfmanList', function()
        render.print_plugin_files(module.list_available(), module.options)
    end, { desc = 'list all plugins' })
    vim.api.nvim_create_user_command('ConfmanInfo', function()
        render.print_plugin_files(module.list_enabled(), module.options)
    end, { desc = 'list enabled plugins' })
    vim.api.nvim_create_user_command('ConfmanEnable', module.enable_command, { desc = 'enable plugin', bang = true })
    vim.api.nvim_create_user_command('ConfmanDisable', module.disable_command, { desc = 'disable plugin' })
    vim.api.nvim_create_user_command('Confman', function()
        local all_plugins = module.list_available()
        local converted = require'confman.confitem'.convert(all_plugins)
        require'confman.ui.dialog'.show_plugins(converted)
    end, { desc = 'show Confman UI' })
end

M.unload = function()
    for c, i in pairs(vim.api.nvim_get_commands({builtin = false})) do
       if vim.startswith(c, 'Confman') then
           vim.api.nvim_del_user_command(c)
       end
    end
    package.loaded['confman.commands'] = nil
    return M
end

return M
