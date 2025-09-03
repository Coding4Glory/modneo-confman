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

---@param category string the plugin category
---@param filename string must be the exact basename (with suffix)
local function get_link_name(category, filename)
    local config = require('modneo-confman.config')
    return vim.fs.joinpath(
        config.get_plugin_dir(),
        config.options.link_dir,
        category .. '-' .. filename
    )
end

---@type Modneo.Confman.Core.Strategy
return {
    enable_conf = function(item, force)
        local dst_file = get_link_name(item.category, item.name)
        if vim.uv.fs_stat(dst_file) then
            if not (force or false) then
                if vim.uv.fs_realpath(dst_file) ~= item.realpath then
                    vim.print(
                        '!! Link has different target, add bang ! to override'
                    )
                    return
                end
                vim.print(
                    '!! Plugin already enabled, add bang ! to recreate link'
                )
                return
            end
            vim.uv.fs_unlink(dst_file)
        end

        vim.uv.fs_symlink(item.realpath, dst_file)
        item.enabled = true
    end,

    disable_conf = function(item)
        local link_file = get_link_name(item.category, item.name)
        if vim.uv.fs_stat(link_file) ~= nil then
            vim.uv.fs_unlink(link_file)
            item.enabled = false
        end
    end,
}
