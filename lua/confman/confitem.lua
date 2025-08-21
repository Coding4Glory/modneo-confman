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

---@class ConfmanConfItemFactory
---@field options ConfmanOptions
local F = {}

F.options = require('confman.config').options

---creates a new ConfmanConfItem
---@see ConfmanConfItem
---@return ConfmanConfItem
F.new = function()
    ---@class ConfmanConfItem
    ---@field category string the plugin category
    ---@field name string the name of the plugin config file
    ---@field line_number integer contains the line number after set_line was called
    ---@field abspath string the absolute path to the plugin file
    ---@field enabled boolean a value indicating if the plugin is enabled
    local M = {}

    ---initializes the instance
    ---@param path string the absolute path to the plugin
    ---@param enabled boolean? a value indicating if the plugin is enabled
    ---@return ConfmanConfItem
    M.init = function(path, enabled)
        M.category = vim.fs.basename(vim.fs.dirname(path))
        M.name = vim.fs.basename(path)
        M.abspath = path
        M.enabled = enabled or M.category == F.options.link_dir
        M.line_number = 0
        return M
    end

    ---enables this plugin
    ---@param force boolean?
    ---@see TinyConfmanCore.enable
    M.enable = function(force)
        require('confman.core').enable(M.category, M.name, force)
    end

    ---disables this plugin
    ---@see TinyConfmanCore.disable
    M.disable = function()
        require('confman.core').disable(M.name)
    end

    return M
end

---creates a table of ConfmanConfItem instances based on the passed table
---@param plugins table
---@return table a categorized table with ConfmanConfItem lists as values
F.convert = function(plugins)
    ---aligns the table so enabled plugins are marked as such
    local function align_enabled(converted, enabled)
        for _, pl in pairs(converted) do
            for _, p in ipairs(pl) do
                if enabled[p.name] ~= nil then
                    p.enabled = true
                end
            end
        end
    end

    ---used to avoid redundant code below
    ---@param enabled table
    ---@param item ConfmanConfItem
    local function enabled_action(enabled, item)
        if item.enabled then
            enabled[item.name] = true
            return true
        end
        return false
    end

    local result = {}
    local enabled = {}

    if plugins == nil then
        return result
    end

    -- simple table without categories
    if table.maxn(plugins) > 0 then
        for _, p in ipairs(plugins) do
            local item = F.new().init(p)
            if not enabled_action(enabled, item) then
                if result[item.category] == nil then
                    result[item.category] = {}
                end
                table.insert(result[item.category], item)
            end
        end
        align_enabled(result, enabled)
        return result
    end

    -- already categorized
    for c, pl in pairs(plugins) do
        local converted = {}
        if pl ~= nil and type(pl) == 'table' then
            for _, p in ipairs(pl) do
                local item = F.new().init(p)
                if not enabled_action(enabled, item) then
                    table.insert(converted, item)
                end
            end
        end
        result[c] = converted
    end
    align_enabled(result, enabled)
    return result
end

return F
