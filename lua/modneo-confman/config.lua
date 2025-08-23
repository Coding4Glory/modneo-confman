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

---@class Modneo.ConfmanConfig
local M = {}

---@class Modneo.ConfmanOptions
local defaults = {
    ---The directory where the plugin categories are located, defaults to lua/plugins.
    ---The path is expected to be relative.
    ---@type string
    plugin_lib = vim.fs.joinpath('lua', 'plugins'),
    ---The directory where links to enabled plugins shall be stored
    ---if not existing the directory will be created in the plugin_dir.
    ---@type string
    ---The same directory has to be set in lazy, will be created within plugin_dir
    link_dir = 'enabled',
    ---The directory where the user configuration is stored, defaults to
    ---`~/.config/nvim.` The default value is retrieved via `stdpath` so
    ---setting this value is usually not required and also not recommended doing
    ---so will change the *state* folder for the plugin which in this case defaults
    ---to the config directory by purpose.
    ---@type string
    config_root = vim.fn.stdpath('config'),
    ---The suffix part of a file glob pattern without leading asterisk. It
    ---has to start with a dot (will not be added automatically) except your
    ---system does not use dot's for file suffix separation (is there any
    ---where neovim runs on?). Might be set to .lua to ignore .vim files original
    ---vice versa.
    ---@type string
    default_filter = '.[lv][iu][am]',
    ---the sign used to highlight enabled plugins
    ---@type string
    enabled_sign = '*'
}

---@type Modneo.ConfmanOptions
M.options = defaults

---initializes the configuration
---will accumulate changes if called multiple times
---@param args Modneo.ConfmanOptions?
M.setup = function(args)
    M.options = vim.tbl_deep_extend('force', M.options or defaults, args or {})
    return M.options
end

---reinitializes the configuration from defaults
M.init = function()
    M.options = vim.tbl_deep_extend('keep', defaults, {})
    return M.options
end

return M
