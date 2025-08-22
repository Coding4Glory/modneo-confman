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

---@class ConfmanLoader
local M = {}

local sign_name = require('confman.ui.render').sign.name

local function remove_sign()
    local found = vim.fn.sign_getdefined(sign_name)['name']
    if found ~= nil then
        vim.fn.sign_undefine(found)
    end
end

---@param sign string
local function add_sign(sign)
    remove_sign()
    vim.fn.sign_define(sign_name, { text = sign, texthl = 'Bold' })
end

---initializes the plugin with default options
M.init = function()
    local options = require('confman.config').init()
    add_sign(options.enabled_sign)
    local core = require('confman.core').init()
    require('confman.commands').setup(core)
end

---performs plugin setup with given options
---@param opts ConfmanOptions? custom settings
---@return ConfmanCore
M.setup = function(opts)
    local options = require('confman.config').setup(opts)
    add_sign(options.enabled_sign)
    local core = require('confman.core').init()
    if package.loaded['confman.commands'] == nil then
        require('confman.commands').setup(core)
        return core
    end
    require('confman.commands').remove().setup(core)
    return core
end

---removes the plugin as far as possible
M.remove = function()
    require('confman.commands').remove()
    remove_sign()
    local to_remove = {
        'confman.ui.dialog',
        'confman.ui.render',
        'confman.ui.floatsize',
        'confman.health',
        'confman.confitem',
        'confman.core',
        -- 'confman.commands', -- removes itself
        'confman.config',
    }
    for _, pack in ipairs(to_remove) do
        if package.loaded[pack] ~= nil then
            package.loaded[pack] = nil
        end
    end
end

---calls rmove and afterwards setup
---@param opts ConfmanOptions? custom settings
M.reload = function(opts)
    M.remove()
    M.setup(opts)
end

return M
