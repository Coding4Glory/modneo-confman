--[[
confman.nvim
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
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

local config = require('modneo-confman.config')

local helper = require('modneo-confman.helper')

local search = {
    config.options.default_filter,
    config.options.default_filter .. config.options.disabled_suffix,
}

local function get_file_patterns(name)
    local i = 0
    local last = #search

    name = name or '*'

    return function ()
        i = i + 1
        if i <= last then
            if name:match('.%' .. search[i] .. '$') == nil then
                return name .. search[i]
            end
            return name
        end
    end
end

---renames the file
---@param item Modneo.Confman.ConfItem the item to rename
---@param new_basename string the new basename
local function rename(item, new_basename)
    local new_path =
        vim.fs.joinpath(vim.fs.dirname(item.realpath), new_basename)
    if new_path == item.realpath then
        return
    end
    vim.uv.fs_rename(item.realpath, new_path)
    item.refresh(new_path)
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
---@param basedir string the base directory to start the search from
---@param folder string? simple folder name
---@param pattern string file pattern to match agains
---@return table
local function get_files(basedir, folder, pattern)
    local search_path =
        vim.fs.joinpath(basedir, folder or '*', pattern)
print (search_path)
    return vim.fn.glob(search_path, false, true, true)
end

---@class Modneo.Confman.Strategies.RenameBase
local M = {}

---enables the item if disabled by name, bang is ignored by this strategy
---@param item Modneo.Confman.ConfItem
---@param _ boolean
M.enable_conf = function(item, _)
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
end

---disables the item if enabled by name
---@param item Modneo.Confman.ConfItem
M.disable_conf = function(item)
    local new_name = get_disabled_name(item)
    rename(item, new_name)
    item.enabled = false
end

---checks if the disabled suffix is present
---@param item Modneo.Confman.ConfItem
M.is_enabled = function(item)
    return not vim.endswith(
        (item.realpath or item.abspath),
        config.options.disabled_suffix
    )
end

---gets the first config file matching category and name
---@param category string the category of the config item to find
---@param name string
---@return string?
M.find = function(category, name)
    for p in get_file_patterns(name) do
        local found = get_files(M.basedir, category, p)
        if #found == 1 then
            return found[1]
        end
    end
end

---retrieves configs from all categories
---@param category string the category to filter on
---@return string[]
M.get_configs = function(category)
    if category == config.options.link_dir then
        return {}
    end
    local found = {}
    for p in get_file_patterns() do
        local in_cat = get_files(M.basedir, category, p)
        found = helper.tbl_merge(found, in_cat)
    end

    return found
end


---retrieves a list of files without the disabled suffix
---@return string[]
M.get_enabled = function()
    return get_files(M.basedir, nil, config.options.default_filter)
end

---creates the derived class
---@param dir string directory to start from
---@param name string the name of the derivative
---@param C table
---regular strategy starts from plugin directory, autoload from config root
---@return Modneo.Confman.Core.Strategy
M.derive = function(dir, name, C)
    M.basedir = dir
    M.name = function() return name end
    setmetatable(C, { __index = M })
    return C
end

return M
