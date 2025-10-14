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

---@class Modneo.ConfmanLoader
local M = {}

local signs = require('modneo-confman.ui.signs')

---performs plugin setup with given options
---@param opts Modneo.Confman.Options? custom settings
---@return Modneo.ConfmanCore
M.setup = function(opts)
    local options = require('modneo-confman.config').setup(opts)
    signs.setup(options)
    local core = require('modneo-confman.core').init()
    require('modneo-confman.commands').remove().setup(core)
    return core
end

---initializes the plugin with default options
M.init = function()
    M.setup({})
end
---removes the plugin as far as possible
M.remove = function()
    require('modneo-confman.commands').remove()
    signs.unload()
    local to_remove = {
        'modneo-confman.ui.dialog',
        'modneo-confman.ui.render',
        'modneo-confman.ui.floatsize',
        'modneo-confman.health',
        'modneo-confman.confitem',
        'modneo-confman.core',
        -- 'modneo-confman.commands', -- removes itself
        'modneo-confman.config',
    }
    for _, pack in ipairs(to_remove) do
        if package.loaded[pack] ~= nil then
            package.loaded[pack] = nil
        end
    end
end

---calls rmove and afterwards setup
---@param opts Modneo.Confman.Options? custom settings
M.reload = function(opts)
    M.remove()
    M.setup(opts)
end

return M
