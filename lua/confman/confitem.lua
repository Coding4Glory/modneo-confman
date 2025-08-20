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
return {
    ---creates a new ConfmanConfItem
    ---@see ConfmanConfItem
    new = function()
        ---@class ConfmanConfItem
        ---@field category string the plugin category
        ---@field name string the name of the plugin config file
        ---@field line_number integer contains the line number after set_line was called
        local M = {}

        ---initializes the instance
        ---@param path string the absolute path to the plugin
        ---@param enabled boolean? a value indicating if the plugin is enabled
        M.init = function(path, enabled)
            M.category = vim.fs.basename(vim.fs.dirname(path))
            M.name = vim.fs.basename(path)
            M.abspath = path
            M.enabled = enabled or false
            return M
        end

        ---@param num integer the line number the item got added to
        M.set_line = function(num)
            M.line_number = num
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
    end
}

