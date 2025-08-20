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

---@class ConfmanConfig
local M = {}

---@class ConfmanOptions
---@field link_dir string name of the directory to create the symlinks
---the same directory has to be set in lazy, will be created within plugin_dir
local defaults = {

    ---the directory (within lua) where the plugins configurations
    ---are located defaults to plugins
    ---@type string 
    plugin_dir = 'plugins',
    ---the directory where links to enabled plugins shall be stored
    ---@type string
    link_dir = 'enabled',
    ---the directory where the user configuration is stored, defaults to
    ---`~/.config/nvim/lua.` the default value is retrieved via `stdpath`
    ---@type string
    config_dir = vim.fs.joinpath(vim.fn.stdpath('config'), 'lua'),
}

---@type ConfmanOptions
M.options = defaults

---initializes the configuration
---will accumulate changes if called multiple times
---@param args ConfmanOptions
M.setup = function(args)
    M.options = vim.tbl_deep_extend('force', M.options, args or {})
    return M.options
end

---reinitializes the configuration from defaults
---@param args ConfmanOptions
M.init = function(args)
    M.options = vim.tbl_deep_extend('force', defaults, args or {})
    return M.options
end

return M
