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

local render = require('modneo-confman.ui.render').init()

---@class Modneo.ConfmanCommands
local M = {}

---@type function
---adds the plugin commands
---@param core Modneo.ConfmanCore
M.setup = function(core)
    local function complete_helper(argLead, cmdLine, cursorPos)
        local proto_cat = argLead:match('(.+)/.*')
        if proto_cat == nil then
           return core.get_categories()
        end
        if vim.startswith(cmdLine, 'ConfmanEnable') then
            return core.get_category(proto_cat)
        end
        -- ConfmanDisabled
        local enabled = {}
        for _, p in core.list_enabled()[core.options.link_dir] do
            table.insert(enabled, string.format("%s/%p", p.category,  p.name))
        end
        return enabled
    end

    vim.api.nvim_create_user_command('ConfmanList', function()
        render.print_plugin_files(core.list_available())
    end, { desc = 'list all plugins' })
    vim.api.nvim_create_user_command('ConfmanInfo', function()
        local enabled = core.list_enabled()
        if #enabled == 0 then
            vim.notify('no enabled plugins found', vim.log.levels.INFO)
            return
        end
        render.print_plugin_files(enabled)
    end, { desc = 'list enabled plugins' })
    vim.api.nvim_create_user_command('ConfmanEnable', core.enable_command,
        { desc = 'enable plugin', bang = true, nargs = 1, complete = complete_helper })
    vim.api.nvim_create_user_command('ConfmanDisable', core.disable_command,
        { desc = 'disable plugin', bang = true, nargs = 1, complete = complete_helper })
    vim.api.nvim_create_user_command('Confman', function()
        local all_configs = vim.tbl_deep_extend('keep', core.get_configs(), core.get_autoloaded())
        require'modneo-confman.ui.dialog'.show_plugins(all_configs)
    end, { desc = 'show Confman UI' })
end

---removes the commands prefixed with Confman
M.remove = function()
    if package.loaded['modneo-confman.commands'] == nil then return M end
    for c, i in pairs(vim.api.nvim_get_commands({builtin = false})) do
       if vim.startswith(c, 'Confman') then
           vim.api.nvim_del_user_command(c)
       end
    end
    package.loaded['modneo-confman.commands'] = nil
    return M
end

return M
