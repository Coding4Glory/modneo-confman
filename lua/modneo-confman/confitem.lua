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
local F = {}

---@param opts Modneo.ConfmanOptions
F.setup = function(opts)
    F.options = opts or require('modneo-confman.config').options
    return F
end

---creates a new ConfmanConfItem
---@see ConfmanConfItem
---@return Modneo.ConfmanConfItem
F.new = function(path)
    ---@class Modneo.ConfmanConfItem
    ---@field category string? the plugin category
    ---@field name string the name of the plugin config file
    ---@field line_number integer contains the line number after set_line was called
    ---@field abspath string the absolute path to the plugin file
    ---@field enabled boolean a value indicating if the plugin is enabled
    ---@field realpath string? the actual file path, resolved if symlink
    local M = {}

    ---initializes the instance
    ---@return Modneo.ConfmanConfItem
    M.init = function()
        M.abspath = path
        M.realpath = (vim.uv or vim.loop).fs_realpath(path)
        M.category = vim.fs.basename(vim.fs.dirname(M.realpath))
        M.name = vim.fs.basename(M.realpath) or path
        M.enabled = vim.fs.basename(vim.fs.dirname(M.abspath))
            == F.options.link_dir

        M.line_number = 0
        return M

        -- ---enables this plugin
        -- ---@param force boolean?
        -- ---@see ConfmanCore.enable
        -- M.enable = function(force)
        --     core.enable_conf(M, force)
        --     M.enabled = true
        -- end
        --
        -- ---disables this plugin
        -- ---@see ConfmanCore.disable
        -- M.disable = function()
        --     core.disable_conf(M)
        --     M.enabled = false
        -- end
    end

    return M.init()
end

---creates a table of ConfmanConfItem instances based on the passed table
---@param plugins table
---@param enabled table
---@return table a categorized table with ConfmanConfItem lists as values
F.convert = function(plugins, enabled)
    local result = {}

    if plugins == nil then
        return result
    end

    -- simple table without categories
    if #plugins > 0 then
        for _, file in ipairs(plugins) do
            local item = F.new(file)
            local e = enabled[item.category .. '/' .. item.name]
            if e ~= nil then
                item = e
            end
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
                local item = F.new(file)
                local e = enabled[item.category .. '/' .. item.name]
                if  e ~= nil then
                    converted = e
                end
                table.insert(converted, item)
            end
        end
        result[c] = converted
    end
    return result
end

return F
