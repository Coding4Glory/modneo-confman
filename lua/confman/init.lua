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

---@class TinyConfmanLoader
---@field setup function loads the module
local M = {}

---@param opts ConfmanOptions? custom settings
M.setup = function(opts)
    require('confman.config').setup(opts)
    local module = require('confman.core').init()
    if package.loaded['confman.commands'] == nil then
        require('confman.commands').setup(module)
        return
    end
    require('confman.commands').unload().setup(module)
end
---same as setup but clears packages array first
---@param opts ConfmanOptions? custom settings
M.reload = function(opts)
    require('confman.commands').unload()
    local to_remove = {
        'confman.ui.dialog',
        'confman.ui.render',
        'confman.ui.floatsize',
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
    M.setup(opts)
end

return M
