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

---@class Modneo.ConfmanConfItemFactory
---@field options Modneo.ConfmanOptions
---@field strategy Modneo.Confman.Core.Strategy
local F = {}

F.setup = function()
    F.options = require('modneo-confman.config').options
    F.strategy = require('modneo-confman.strategies')[F.options.strategy]
    return F
end

---creates a new ConfmanConfItem
---@param path string the absolute path to the found config file or symlink
---@param strategy Modneo.Confman.Core.Strategy? allows overriding the configured strategy
---@return Modneo.Confman.ConfItem
---@see Modneo.Confman.ConfItem
F.new = function(path, strategy)
    ---@class Modneo.Confman.ConfItem
    ---@field category string? the plugin category
    ---@field name string the name of the plugin config file
    ---@field line_number integer contains the line number after set_line was called
    ---@field abspath string the absolute path to the plugin file
    ---@field enabled boolean a value indicating if the plugin is enabled
    ---@field realpath string? the actual file path, resolved if symlink
    local M = {}

    strategy = strategy or F.strategy

    ---initializes the instance
    ---@return Modneo.Confman.ConfItem
    M.init = function()
        M.abspath = path
        M.line_number = 0
        M.refresh()
        return M
    end

    --- refreshes the state of the confItem instance
    M.refresh = function()
        M.realpath = (vim.uv or vim.loop).fs_realpath(path)
        M.category = vim.fs.basename(vim.fs.dirname(M.realpath))
        M.name = vim.fs.basename(M.realpath) or M.abspath
        M.enabled = strategy.is_enabled(M)
    end

    ---enables the configuration file described by this item
    ---@param force boolean?
    M.enable = function(force)
        local success, err = pcall(strategy.enable_conf, M, force)
        if not success then
            print(err)
        end
        M.enabled = success
    end

    --- disables the configuration file described by this item
    M.disable = function()
        local success, err = pcall(strategy.disable_conf, M)
        if not success then
            print(err)
        end
        M.enabled = not success
    end

    return M.init()
end

---creates a table of ConfmanConfItem instances based on the passed table
---@param plugins table
---@param strategy Modneo.Confman.Core.Strategy?
---@return table<string,Modneo.Confman.ConfItem> a categorized table with ConfmanConfItem lists as values
F.convert = function(plugins, strategy)
    local result = {}

    if plugins == nil then
        return result
    end

    -- simple table without categories
    if #plugins > 0 then
        for _, file in ipairs(plugins) do
            local item = F.new(file, strategy)
            if result[item.category] == nil then
                result[item.category] = {}
            end
            table.insert(result[item.category], item)
        end
        return result
    end

    -- already categorized
    -- will no longer be required soon
    for c, pl in pairs(plugins) do
        local converted = {}
        if pl ~= nil and type(pl) == 'table' then
            for _, file in ipairs(pl) do
                local item = F.new(file, strategy)
                table.insert(converted, item)
            end
        end
        result[c] = converted
    end
    return result
end

return F
