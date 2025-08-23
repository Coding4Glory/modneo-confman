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

return {
    check = function()
        local options = require'modneo-confman.config'.options
        if options == nil then
            vim.health.error('modneo-confman is not configured properly')
            return
        end

        local core = require'modneo-confman.core'

        local plugin_dir = core.get_plugin_dir()
        if (vim.uv or vim.loop).fs_stat(plugin_dir) ~= nil then
            local cats = core.get_configs()
            local cat_count = 0
            local plug_count = 0
            for _, pl in pairs(cats) do
                cat_count = cat_count + 1
                if pl ~= nil then
                    for _,_ in ipairs(pl) do
                        plug_count = plug_count + 1
                    end
                end
            end
            vim.health.ok(string.format('plugin directory exists, %i categories with %i plugins', cat_count, plug_count))
        else
            vim.health.error(string.format('plugin directory [%s] does not exist', plugin_dir))
        end

        local enabled_dir = vim.fs.joinpath(core.get_plugin_dir(), options.link_dir)
        if (vim.uv or vim.loop).fs_stat(plugin_dir) ~= nil then
            vim.health.ok('enabled-plugin directory exists ' .. table.maxn(vim.fn.glob(vim.fs.joinpath(enabled_dir, '*'), false, true, false)) .. ' files found')
        else
            vim.health.error(string.format('enabled-plugin directory [%s] does not exist', enabled_dir))
        end
    end
}
