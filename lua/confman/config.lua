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
local defaults = {
    ---the directory where the plugin categories
    ---are located, defaults to lua/plugins
    ---@type string 
    plugin_dir = vim.fs.joinpath('lua', 'plugins'),
    ---the directory where links to enabled plugins shall be stored
    ---if not existing the directory will be created in the plugin_dir.
    ---@type string
    ---The same directory has to be set in lazy, will be created within plugin_dir
    link_dir = 'enabled',
    ---the directory where the user configuration is stored, defaults to
    ---`~/.config/nvim.` the default value is retrieved via `stdpath`
    ---@type string
    config_dir = vim.fn.stdpath('config'),
    ---the suffix part of a file glob pattern without leading asterisk
    ---has to start with a dot (will not be added automatically) except your system
    ---does not use dot's for file suffix separation (is there any where neovim runs on?).
    ---@type string 
    default_filter = '.[lv][iu][am]',
}

---@type ConfmanOptions
M.options = defaults

---initializes the configuration
---will accumulate changes if called multiple times
---@param args ConfmanOptions
M.setup = function(args)
    M.options = vim.tbl_deep_extend('force', M.options or defaults, args or {})
    return M.options
end

---reinitializes the configuration from defaults
---@param args ConfmanOptions
M.init = function(args)
    M.options = vim.tbl_deep_extend('force', defaults, args or {})
    return M.options
end

return M
