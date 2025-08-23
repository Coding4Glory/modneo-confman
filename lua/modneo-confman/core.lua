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

---@class Modneo.ConfmanCore
---@field options Modneo.ConfmanOptions
---@field item_factory Modneo.ConfmanConfItemFactory
---@field uv uv
local M = {}

---@type Modneo.ConfmanOptions
M.options = {}

---gets the glob pattern for the given filename using the default_filter value
---@param name string? the filename, ommitting or nil will result in an asterisk `*`.
M.get_file_pattern = function(name)
    name = name or '*'
    if name:match('.+%' .. M.options.default_filter .. '$') == nil then
        return name .. M.options.default_filter
    end
    --- has already a matching suffix
    return name
end

---@return string
M.get_plugin_dir = function()
    return vim.fs.joinpath(M.options.config_root, M.options.plugin_lib)
end

---@param category string the plugin category
---@param filename string must be the exact basename (with suffix)
M.get_link_name = function(category, filename)
    return vim.fs.joinpath(
        M.get_plugin_dir(),
        M.options.link_dir,
        category .. '-' .. filename
    )
end

---gets a list with all plugin categories
---@return table
M.get_categories = function()
    local r = {}
    for name, type in vim.fs.dir(M.get_plugin_dir()) do
        if type == 'directory' then
            table.insert(r, name)
        end
    end
    return r
end

M.get_category = function(cat)
    local r = {}
    for name, type in vim.fs.dir(vim.fs.joinpath(M.get_plugin_dir(), cat)) do
        if type == 'file' then
            table.insert(r, cat .. '/' .. name)
        end
    end
    return r

end

---gets a list with all plugins
---@param category string? may be used to restrict to specific category
M.get_configs = function(category)
    local enabled = {}
    if category ~= M.options.link_dir then
        for _, l in pairs(M.get_configs(M.options.link_dir)) do
            for _, e in ipairs(l) do
                enabled[e.category .. '/' .. e.name] = e
            end
        end
    end

    local search_path = vim.fs.joinpath(
        M.get_plugin_dir(),
        category or '*',
        M.get_file_pattern()
    )
    local plugins_files = vim.fn.glob(search_path, false, true, true)
    return M.item_factory.convert(plugins_files, enabled)
end

local function single_result_to_item(found)
if type(found) == 'string' then
        return M.item_factory.new(found)
    elseif type(found) == 'table' and #found == 1 then
        return M.item_factory.new(found[1])
    end
end

---gets a single item by category and name
---Modneo.ConfmanConfItem?
---if the name is occupied multiple times (e. g. with .lua and .vim) pass
---the name with the suffix appended
M.get_item = function(category, name)
    local found = M.get_enabled_conf(category, name)
    if found ~= nil then return found end

    local search_path = vim.fs.joinpath(
        M.get_plugin_dir(),
        category,
        M.get_file_pattern(name)
    )
    found = vim.fn.glob(search_path, false, true, false)

    return single_result_to_item(found)
end

---Gets the enable configuration with the given category and name
---if found, otherwise nil.
---@param cat string the plugin category
---@param name string the plugin name
---@return Modneo.ConfmanConfItem?
M.get_enabled_conf = function(cat, name)
    local search_path = vim.fs.joinpath(
        M.get_plugin_dir(),
        M.options.link_dir,
        M.get_file_pattern(cat .. '-' .. name)
    )
    local found = vim.fn.glob(search_path, false, true, false)

    return single_result_to_item(found)
end

---lists all available plugins
---@type function
M.list_available = function()
    return M.get_configs()
end

---lists the enabled plugins
---@type function
M.list_enabled = function()
    return M.get_configs(M.options.link_dir)
end

---enables the given config item
---@type function
---@param item Modneo.ConfmanConfItem
M.enable_conf = function(item, force)
    local dst_file = M.get_link_name(item.category, item.name)
    if M.uv.fs_stat(dst_file) then
        if not (force or false) then
            if M.uv.fs_realpath(dst_file) ~= item.realpath then
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
        M.uv.fs_unlink(dst_file)
    end

    M.uv.fs_symlink(item.realpath, dst_file)
    item.enabled = true
end

---enables the given configuration file or a whole category
---@param category string module category
---@param name string? the name of the config file within the category, pass nil to enable whole category
---@param force boolean? force re-enabling / overriding
M.enable = function(category, name, force)
    if name ~= nil and name ~= '' then
        local item = M.get_item(category, name)
        if item == nil then
            error(
                string.format(
                    'Config file matching %s/%s not found in %s',
                    category,
                    name,
                    M.get_plugin_dir()
                )
            )
        end
        M.enable_conf(item, force)
        return
    end

    local all_from_cat = M.get_configs(category)
    for _, x in ipairs(all_from_cat[category]) do
        M.enable_conf(x)
    end
end

---enables the given plugin
---@type function
---@param opts vim.api.keyset.create_user_command.command_args
M.enable_command = function(opts)
    for cat, mod in string.gmatch(opts.args, '([%._%-%w]+)[/\\]([%._%-%w]+)') do
        M.enable(cat, mod, opts.bang)
    end
end

---disables the given config item
---@type function
---@param item ConfmanConfItem
M.disable_conf = function(item)
    local link_file = M.get_link_name(item.category, item.name)
    if M.uv.fs_stat(link_file) ~= nil then
        M.uv.fs_unlink(link_file)
        item.enabled = false
    end
end

---disables the plugin identified by category and name
---@param cat string the plugin category
---@param name string the name of the config file
---@param force boolean? disables the module, even if not expected
M.disable = function(cat, name, force)
    local found = M.get_item(M.options.link_dir, cat .. '-' .. name)
    if found == nil then
        error('link to disable not found')
    end

    local expected = M.get_item(cat, name)
    if expected ~= nil and expected.realpath == found.realpath then
        M.disable_conf(expected)
        return
    end

    -- fallback for orphaned
    if force or false then
        M.uv.fs_unlink(found.abspath)
        return
    end
    warn('link found, but not matching item. Use bang ! to remove anyway')
end

---disables the given plugin
---expects a category/name combination in args
---@type function
---@param opts vim.api.keyset.create_user_command.command_args
M.disable_command = function(opts)
    for cat, mod in string.gmatch(opts.args, '([%._%-%w]+)[/\\]([%._%-%w]+)') do
        M.disable(cat, mod, opts.bang)
    end
end

---@type function
---@return boolean true if the plugin is enabled, otherwise false
M.enabled = function(cat, name)
    local found = M.get_enabled_conf(cat, name)
    if found ~= nil then
        return true
    end
    return false
end

---call on require to apply settings
---@type function
---@return Modneo.ConfmanCore
M.init = function()
    M.options = require('modneo-confman.config').options
    M.item_factory = require('modneo-confman.confitem').setup(M.options)
    M.uv = (vim.uv or vim.loop)
    return M
end

return M
