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

local search = {
    config.options.default_filter,
    config.options.disabled_suffix,
}
---renames the file
---@param item Modneo.Confman.ConfItem the item to rename
---@param new_basename string the new basename
local function rename(item, new_basename)
    local new_path = vim.fs.joinpath(item.realpath, new_basename)
    vim.uv.fs_rename(item.realpath, new_path)
end

---strips the suffix if existing
---@param item Modneo.Confman.ConfItem
---@return string?
local function get_enabled_name(item)
    local new_name = vim.fs
        .basename(item.realpath)
        :match('(.*)' .. config.options.disabled_suffix)

    if new_name == nil or new_name == '' then
        -- appearently not disabled - return current name to prevent damage
        return vim.fs.basename(item.realpath)
    end
end

---@param item Modneo.Confman.ConfItem
---@return string
local function get_disabled_name(item)
    return vim.fs.basename(item.realpath) .. config.options.disabled_suffix
end

local function get_files(folder, pattern)
    local search_path =
        vim.fs.joinpath(config.get_plugin_dir(), folder or '*', pattern)
    return vim.fn.glob(search_path, false, true, true)
end

---@type Modneo.Confman.Core.Strategy
local M = {
    enable_conf = function(item, _)
        local new_name = get_enabled_name(item)
        if new_name == nil then
            error(
                'could not enable '
                    .. item.name
                    .. ' file might not exist anymore'
            )
        end
        rename(item, new_name)
        item.enabled = true
    end,

    disable_conf = function(item, _)
        local new_name = get_disabled_name(item)
        rename(item, new_name)
        item.enabled = false
    end,

    is_enabled = function(item)
        return not vim.endswith(
            vim.fs.basename(item.realpath or item.abspath),
            config.options.disabled_suffix
        )
    end,

    find = function(category, name)
        for _, p in ipairs(search) do
            return get_files(category, config.get_file_pattern(name, p))[1]
        end
    end,

    get_configs = function(category)
        local found = {}
        for _, p in ipairs(search) do
            found =
                vim.tbl_deep_extend('error', get_files(category, p), found)
        end

        return found
    end,
}

return function (S)
    S['rename'] = M
end
