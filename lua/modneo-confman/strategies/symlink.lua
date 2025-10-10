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

local config = require('modneo-confman.config')

---@param category string the plugin category
---@param filename string must be the exact basename (with suffix)
local function get_link_name(category, filename)
    return vim.fs.joinpath(
        config.get_plugin_dir(),
        config.options.link_dir,
        category .. '-' .. filename
    )
end

local function get_files(folder, enabled)
    local search_path = vim.fs.joinpath(
        config.get_plugin_dir(),
        folder or '*',
        config.get_file_pattern()
    )

    local found = vim.fn.glob(search_path, false, true, true)
    for i, f in ipairs(found) do
        found[i] = enabled[f] or f
    end
    return found
end

---@type Modneo.Confman.Core.Strategy
local M = {
    enable_conf = function(item, force)
        local dst_file = get_link_name(item.category, item.name)
        if vim.uv.fs_stat(dst_file) ~= nil then
            if not (force or false) then
                if vim.uv.fs_realpath(dst_file) ~= item.realpath then
                    error(
                        '!! Link has different target, add bang ! to override'
                    )
                end
                error(
                    '!! Plugin already enabled, add bang ! to recreate link'
                )
            end
            vim.uv.fs_unlink(dst_file)
        end

        vim.uv.fs_symlink(item.realpath, dst_file)
        item.abspath = dst_file
    end,

    disable_conf = function(item)
        local link_file = get_link_name(item.category, item.name)
        if vim.uv.fs_stat(link_file) ~= nil then
            vim.uv.fs_unlink(link_file)
        end
    end,

    is_enabled = function(item)
        return vim.fs.basename(vim.fs.dirname(item.abspath))
            == config.options.link_dir
    end,

    find = function(category, name)
        local pattern = vim.fs.joinpath(
            config.get_plugin_dir(),
            category,
            config.get_file_pattern(name)
        )
        local found = vim.fn.glob(pattern, false, true, false)
        if #found == 1 then
            local link = get_link_name(category, vim.fs.basename(found[1]))
            if vim.uv.fs_stat(link) ~= nil then
                return link
            end
            return found[1]
        end
        return nil
    end,

    get_configs = function(category)
        local enabled = {}
        if category ~= config.options.link_dir then
            for _, l in pairs(get_files(config.options.link_dir, {})) do
                enabled[vim.uv.fs_realpath(l)] = l
            end
        end

        return get_files(category, enabled)
    end,
}

return function (S)
    S['symlink'] = M
end
