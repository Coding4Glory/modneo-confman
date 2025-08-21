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

---@param opts ConfmanOptions
F.setup = function(opts)
    F.options = opts or require('confman.config').options
    return F
end

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
    ---@param core ConfmanCore
    ---@return ConfmanConfItem
    M.init = function(path, core)
        M.category = vim.fs.basename(vim.fs.dirname(path))
        M.name = vim.fs.basename(path)
        M.abspath = path
        M.realpath = (vim.uv or vim.loop).fs_realpath(path)
        M.enabled = M.category == F.options.link_dir

        ---enables this plugin
        ---@param force boolean?
        ---@see ConfmanCore.enable
        M.enable = function(force)
            core.enable(M.category, M.name, force)
            M.enabled = true
        end
        ---disables this plugin
        ---@see ConfmanCore.disable
        M.disable = function()
            core.disable(M.name)
            M.enabled = false
        end

        -- check enabled to avoid dereferencing links outside enabled folder
        if M.enabled and M.abspath ~= M.realpath then
            M.category = vim.fs.basename(vim.fs.dirname(M.realpath)) or M.category
        end
        M.line_number = 0
        return M
    end
    return M
end

---creates a table of ConfmanConfItem instances based on the passed table
---@param plugins table
---@return table a categorized table with ConfmanConfItem lists as values
F.convert = function(plugins, core)
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
        for _, file in ipairs(plugins) do
            local item = F.new().init(file, core)
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
            for _, file in ipairs(pl) do
                local item = F.new().init(file, core)
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
