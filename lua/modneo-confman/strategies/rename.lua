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
    config.options.default_filter .. config.options.disabled_suffix,
}
---renames the file
---@param item Modneo.Confman.ConfItem the item to rename
---@param new_basename string the new basename
local function rename(item, new_basename)
    local new_path = vim.fs.joinpath(vim.fs.dirname(item.realpath), new_basename)
    if new_path == item.realpath then return end
    vim.uv.fs_rename(item.realpath, new_path)
end

---strips the suffix if existing
---@param item Modneo.Confman.ConfItem
---@return string?
local function get_enabled_name(item)
    local new_name = vim.fs
        .basename(item.realpath)
        :match('(.*)' .. config.options.disabled_suffix .. '$')

    if new_name == nil or new_name == '' then
        -- appearently not disabled - return current name
        return vim.fs.basename(item.realpath)
    end

    return new_name
end

---@param item Modneo.Confman.ConfItem
---@return string
local function get_disabled_name(item)
    return vim.fs.basename(item.realpath) .. config.options.disabled_suffix
end

---get files from folder inside plugin directory matching pattern
---@param folder string simple folder name
---@param pattern string file pattern to match agains
---@return any
local function get_files(folder, pattern)
    local search_path =
        vim.fs.joinpath(config.get_plugin_dir(), folder or '*', pattern)
    return vim.fn.glob(search_path, false, true, true)
end

---@type Modneo.Confman.Core.Strategy
local M = {
    ---enables the item if disabled by name, bang is ignored by this strategy
    enable_conf = function(item, _)
        local new_name = get_enabled_name(item)
        if new_name == nil then
            error(
                'could not enable '
                    .. item.category
                    .. '/'
                    .. item.name
                    .. ' file might not exist anymore'
            )
        end
        rename(item, new_name)
        item.enabled = true
    end,

    ---disables the item if enabled by name
    disable_conf = function(item)
        local new_name = get_disabled_name(item)
        rename(item, new_name)
        item.enabled = false
    end,

    ---checks if the disabled suffix is present
    is_enabled = function(item)
        return not vim.endswith(
            vim.fs.basename(item.realpath or item.abspath),
            config.options.disabled_suffix
        )
    end,

    ---gets the first config file matching category and name
    find = function(category, name)
        for _, p in ipairs(search) do
            local found = get_files(category, config.get_file_pattern(name, p))
            if #found == 1 then return found[1] end
        end
    end,

    ---retrieves configs from all categories
    get_configs = function(category)
        if category == config.options.link_dir then return {} end
        local found = {}
        for _, p in ipairs(search) do
            local in_cat = get_files(category, '*' .. p)
            for _, x in ipairs(in_cat) do
                if not vim.tbl_contains(found, x) then
                    table.insert(found, x)
                end
            end
        end

        return found
    end,

    name = function() return 'rename' end,
}

return function (S)
    config = require('modneo-confman.config')
    S['rename'] = M
end
