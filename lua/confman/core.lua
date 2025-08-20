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

---@class TinyConfmanCore
---@field options ConfmanOptions
local M = {}

---@type ConfmanOptions
---@private
M.options = {}

---@param settings ConfmanOptions
---@return string
local function get_plugin_dir(settings)
    return vim.fs.joinpath(settings.config_dir, settings.plugin_dir)
end

---@param settings ConfmanOptions
---@param name string
local function get_link_file(settings, name)
    return vim.fs.joinpath(settings.config_dir, settings.plugin_dir, settings.link_dir, name)
end

---Gets the files in basepath maching the given filter.
---If no filter is given only files or directories not containing dots will be returned.
---@param basepath any
---@param filter string? may be used to apply a glob pattern, can be ommited with null
---@return table
local function get_files(basepath, filter, all_links)
    all_links = all_links or false
    filter = filter or '*.[lv][iu][am]'
    local path = vim.fs.joinpath(basepath, filter)
    return vim.fn.glob(path, false, true, all_links)
end

---gets the categories and their contained files
---@param settings ConfmanOptions
---@param category string? Optional: the category to show
---@return table
local function get_plugins(settings, category)
    if category == nil then print ('nocat') end
    local plugin_path = get_plugin_dir(settings)
    local plugins = {}
    for folder, type in vim.fs.dir(plugin_path) do
        if type ~= 'directory' then goto continue end
        if category ~= nil and category ~= folder then goto continue end

        local cat_key = vim.fs.basename(folder)
        plugins[cat_key] = get_files(vim.fs.joinpath(plugin_path, cat_key), nil, category == settings.link_dir)

        ::continue::
    end
    return plugins
end

---Determines the correct file name
---@param settings ConfmanOptions
---@param category string
---@param name string
local function find_source_file(settings, category, name)
    local path_prefix = vim.fs.joinpath(settings.plugin_dir, category, name)
    local uv = vim.uv or vim.loop
    local found = nil

    for _, suffix in ipairs(get_files(settings)) do
        local proto = vim.endswith(path_prefix, suffix) and path_prefix or path_prefix .. '.' .. suffix
        if uv.fs_stat(proto) then
            found = proto
        end
    end
    return found
end

---lists all available plugins
---@type function
M.list_available = function()
    return get_plugins(M.options)
end

---lists the enabled plugins
---@type function
M.list_enabled = function()
    return get_plugins(M.options, M.options.link_dir)
end

---enables the given configuration file
---@param category string module category
---@param name string the name of the config file within the category
---@param force boolean? force re-enabling / overriding
M.enable = function(cat, mod, force)
    local src_file = find_source_file(M.options, cat, mod)

    if src_file == nil then
        print(string.format('Config file matching %s/%s not found', cat, mod))
        return
    end

    local uv = (vim.uv or vim.loop)
    local dst_file = get_link_file(M.options, mod)
    if uv.fs_stat(dst_file) then
        if not (force or false) then
            print('!! Plugin already enabled call ConfmanEnable! to recreate link')
            return
        end
        uv.fs_unlink(dst_file)
    end

    uv.fs_symlink(src_file, dst_file)
end

---enables the given plugin
---@type function
---@param opts vim.api.keyset.create_user_command.command_args
M.enable_command = function(opts)
    for cat, mod in string.gmatch(opts.args, '([%._%-%w]+)[/\\]([%._%-%w]+)') do
        M.enable(cat, mod, opts.bang)
    end
end

M.disable = function(name)
    local link_file = get_link_file(M.options, name)
    local uv = (vim.uv or vim.loop)
    if uv.fs_stat(link_file) ~= nil then
        uv.fs_unlink(link_file)
    end
end
---disables the given plugin
---expects a category/name combination in args
---@type function
---@param opts vim.api.keyset.create_user_command.command_args
M.disable_command = function(opts)
    for _, mod in string.gmatch(opts.args, '([%._%-%w]+)[/\\]([%._%-%w]+)') do
        M.disable(mod)
    end
end

---@return integer 1 if the link exists otherwise 0
M.enabled = function(cat, name)
    if (vim.uv or vim.loop).fs_stat(get_link_file(M.options, name)) ~= nil then
        return 1
    end
    return 0
end

---call on require to apply settings
---@type function
---@return TinyConfmanCore
M.init = function()
    M.options = require('confman.config').options
    return M
end

return M
