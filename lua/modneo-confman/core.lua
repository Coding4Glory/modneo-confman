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

local helper = require('modneo-confman.helper')

---@class Modneo.Confman.Core.Strategy
---@field enable_conf fun(item:Modneo.Confman.ConfItem,force:boolean?)
---@field disable_conf fun(item:Modneo.Confman.ConfItem)
---@field is_enabled fun(item:Modneo.Confman.ConfItem):boolean
---@field get_configs fun(category:string?):string[]
---@field get_enabled fun():string[]
---@field find fun(category:string,name:string):string?
---@field restore fun(item:Modneo.Confman.ConfItem)
---@field name fun():string

---@class Modneo.Confman
---@field options Modneo.Confman.Options
---@field item_factory Modneo.Confman.ConfItem.Factory
---@field uv uv
local M = {}

---@type Modneo.Confman.Options
M.options = {}

---gets a list with all plugin categories
---@return string[]
M.get_categories = function()
    local r = {}
    for name, type in vim.fs.dir(M.config.get_plugin_dir()) do
        if type == 'directory' then
            table.insert(r, name)
        end
    end
    return r
end

---gets a list of plugin configs within a category
---@return string[]
M.get_category = function(cat)
    local r = {}
    for name, type in
        vim.fs.dir(vim.fs.joinpath(M.config.get_plugin_dir(), cat))
    do
        if type == 'file' then
            table.insert(r, cat .. '/' .. name)
        end
    end
    return r
end

---gets a list with all plugins
---@param category string? may be used to restrict to specific category
M.get_configs = function(category)
    local config_files = M.strategy().get_configs(category)
    return M.item_factory.convert(config_files)
end

---gets a list of config files in automatically loaded or detected
---otherwise by neovim or builtin plugins like ftplugin
---@return table<string,Modneo.Confman.ConfItem>
M.get_autoloaded = function()
    local result = {}
    for dir in M.config.autoexec_iter() do
        local found = M.autoload.get_configs(dir)
        result = helper.tbl_merge(result, found)
    end
    return M.item_factory.convert(result, M.autoload)
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
---@return Modneo.Confman.ConfItem?
M.get_item = function(category, name)
    local found = M.strategy().find(category, name)
    if found ~= nil then
        return single_result_to_item(found)
    end
end

---lists all available plugins
---@return table<string,Modneo.Confman.ConfItem>
M.list_available = function()
    local categorized = M.strategy().get_configs()
    local autoexec = M.autoload.get_configs()
    return vim.tbl_deep_extend(
        'error',
        M.item_factory.convert(categorized),
        M.item_factory.convert(autoexec, M.autoload)
    )
end

---lists the enabled plugins
---@return table<string,Modneo.Confman.ConfItem>
M.list_enabled = function()
    local categorized = M.strategy().get_enabled()
    local autoexec = M.autoload.get_enabled()
    return vim.tbl_deep_extend(
        'error',
        M.item_factory.convert(categorized),
        M.item_factory.convert(autoexec, M.autoload)
    )
end

---enables the given config item
---@type function
---@param item Modneo.Confman.ConfItem
---@param force boolean
---@deprecated Modneo.Confman.ConfItem.enable(boolean)
M.enable_conf = function(item, force)
    M.strategy().enable_conf(item, force)
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
                    M.config.get_plugin_dir()
                )
            )
        end
        item.enable(force)
        return
    end

    local all_from_cat = M.get_configs(category)
    for _, x in ipairs(all_from_cat[category]) do
        x.enable(force)
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
---@param item Modneo.Confman.ConfItem
---@deprecated Modneo.Confman.ConfItem.disable()
M.disable_conf = function(item)
    M.strategy().disable_conf(item)
end

---disables the plugin identified by category and name
---@param cat string the plugin category
---@param name string the name of the config file
---@param force boolean? disables the module, even if not expected
M.disable = function(cat, name, force)
    local found = M.get_item(cat, name)
    if found == nil then
        error('config to disable not found')
    end
    found.disable()
end

---disables the given plugin
---expects a category/name combination in args
---@param opts vim.api.keyset.create_user_command.command_args
M.disable_command = function(opts)
    for cat, mod in string.gmatch(opts.args, '([%._%-%w]+)[/\\]([%._%-%w]+)') do
        M.disable(cat, mod, opts.bang)
    end
end

---@return boolean true if the plugin is enabled, otherwise false
M.enabled = function(cat, name)
    local found = M.strategy().find(cat, name)
    if found ~= nil then
        return M.item_factory.new(found).enabled
    end
    return false
end


---Performs migration from one strategy to the other
---@param to_strategy Modneo.Confman.Config.Strategy
M.migrate = function(to_strategy)
    local next = M.strategy(to_strategy)
    print('migrating from ' .. M.strategy().name() .. ' to ' .. to_strategy)
    for _, l in pairs(M.list_available()) do
        for _, p in ipairs(l) do
            local migitem = M.item_factory.new(p.realpath, next)
            local was_enabled = p.enabled
            M.strategy().restore(p)
            if was_enabled then
                migitem.enable()
            elseif migitem.enabled then
                migitem.disable()
            end
        end
    end
    M.options = require('modneo-confman.config').setup({ strategy = to_strategy })
    M.item_factory = require('modneo-confman.confitem').setup()
    vim.notify(
        'Config migrated and session reinitialized, but settings must be changed manually',
        vim.log.levels.WARN
    )
end

---call on require to apply settings
---@return Modneo.Confman
M.init = function()
    M.config = require('modneo-confman.config')
    M.options = M.config.options
    M.item_factory = require('modneo-confman.confitem').setup()
    M.strategies = require('modneo-confman.strategies').init()
    ---gets the given strategy or the default strategy if ommited
    ---@param which Modneo.Confman.Config.Strategy?
    ---@return Modneo.Confman.Core.Strategy
    M.strategy = function(which)
        return M.strategies[which or M.options.strategy]
    end
    M.autoload = require('modneo-confman.strategies.autoload')
    M.uv = (vim.uv or vim.loop)
    return M
end

return M
