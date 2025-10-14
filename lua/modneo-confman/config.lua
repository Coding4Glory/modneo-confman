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

---@class Modneo.Confman.Config
local M = {}

---@alias Modneo.ConfmanStrategy
---| 'symlink' uses symlinks for activation
---| 'rename' appends suffix to deactivate

local strategies = { 'symlink', 'rename' }

---@class Modneo.Confman.Options
---@field get_plugin_dir? fun():string will be added during setup
local defaults = {
    ---The directory where the plugin categories are located, defaults to
    ---lua/plugins. The path is expected to be relative.
    ---@type string
    plugin_lib = vim.fs.joinpath('lua', 'plugins'),
    ---The strategy to use to distinguish between enabled and disabled
    ---configurations. This setting defines if following options are
    ---considered. Possible options are 'symlink' and 'rename', defaults to
    ---'symlink' on linux and 'rename' on windows.
    ---Autoload directories like ftplugin will always use rename strategy
    ---@type Modneo.ConfmanStrategy
    strategy = vim.startswith((vim.uv or vim.loop).os_uname().sysname, 'Windows')
             and 'rename'
             or 'symlink',
    ---The suffix to add to disabled files if the strategy is set to rename
    disabled_suffix = '.off',
    ---This setting is only considered for the *symlink* strategy.
    ---The directory where links to enabled plugins shall be stored.
    ---It needs to be created in the plugin_dir. The same directory has to
    ---be set in lazy.
    ---@type string
    link_dir = 'enabled',
    ---The directory where the user configuration is stored, defaults to
    ---`~/.config/nvim.` The default value is retrieved via `stdpath` so
    ---setting this value is usually not required and also not recommended
    ---doing so will change the *state* folder for the plugin which in
    ---this case defaults to the config directory by purpose.
    ---@type string
    config_root = vim.fn.stdpath('config'),
    ---The suffix part of a file glob pattern without leading asterisk.
    ---It has to start with a dot (will not be added automatically) except
    ---your system does not use dot's for file suffix separation (is there
    ---any where neovim runs on?). Might be set to .lua to ignore .vim
    ---files or vice versa.
    ---@type string
    default_filter = '.[lv][iu][am]',
    ---the sign used to highlight enabled plugins in the dialog window
    ---@type string
    ---@deprecated use signes.enabled instead
    enabled_sign = '*',
    ---signs aka icons to use within the dialog
    ---@class Modneo.Confman.Options.Signs
    signs = {
        ---the character used to highlight enabled configs
        ---in *plugin_lib*
        config = '+',
        ---the character used to mark categories
        category = '*',
        ---the character used to mark autoexec folders
        autoload = '*',
    }
}

---@type Modneo.Confman.Options
M.options = defaults

---initializes the configuration
---will accumulate changes if called multiple times
---@param args Modneo.Confman.Options?
M.setup = function(args)
    M.options = vim.tbl_deep_extend('force', M.options, args or {})
    M.options.get_plugin_dir = function()
        return vim.fs.joinpath(M.options.config_root, M.options.plugin_lib)
    end
    if not vim.tbl_contains(strategies, M.options.strategy) then
        error('Strategy ' .. strategies ' .. is not supported!')
    end
    return M.options
end

M.get_plugin_dir = function ()
    return vim.fs.joinpath(
        (M.options.config_root or vim.fn.stdpath('config')),
        M.options.plugin_lib
    )
end

---gets the glob pattern for the given filename using the default_filter value
---@param name string? the filename, ommitting or nil will result in an asterisk `*`.
---@param filter string? an optional filter to override the default
M.get_file_pattern = function(name, filter)
    name = name or '*'
    if name:match('.+%' .. (filter or M.options.default_filter) .. '$') == nil then
        return name .. (filter or M.options.default_filter)
    end
    --- has already a matching suffix
    return name
end

local autoload = {
    'plugin',
    'ftplugin',
    'ftdetect',
}

---gets an iterator only returning the folders no indizes
---*Example:*
---```
---local config = requrie('modneo-confman.config')
---for folder in config.autoexec_iter() do
---   --...
---done
---```
---@return Iterator
M.autoexec_iter = function()
    local i = 0
    local j = #autoload

    return function()
        i = i + 1
        if i <= j then return autoload[i] end
    end
end

---gets a value indicating if the given folder
---is an autoexec folder
M.is_autoload = function(folder)
    return vim.tbl_contains(autoload, folder)
end

return M
