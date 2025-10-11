--[[
confman.nvim
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
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

---Merges code from different files regarding signs into one file
---@class Modneo.Confman.UI.Signs
local M = {
    group = 'ConfmanSigns',
    ---@class Modneo.Confman.UI.Signs.Kind
    signs = {
        ---the sign name used by the plugin for enabled configs
        ---@type string
        config = 'ConfmanEnabled',
        ---the sign name used by the plugin for categories
        ---@type string
        category = 'ConfmanCategory',
    },
}

---Registeres the signs according to given opts
---@param opts Modneo.Confman.Options
M.setup = function(opts)
    vim.fn.sign_define(M.signs.config, { text = opts.signs.enabled, texthl = 'Directory' })
    vim.fn.sign_define(M.signs.category, { text = opts.signs.category, texthl = 'Special' })
end

---Removes the signs from nvim
M.unload = function()
    for _, s in ipairs({ M.signs.config, M.signs.category }) do
        local found = vim.fn.sign_getdefined(s)['name']
        if found ~= nil then
            vim.fn.sign_undefine(found)
        end
    end
end

---Reloads the plugin with given settings. This is equivalent of calling
---```
---M.unload()
---M.setup(opts)
---```
---@param opts Modneo.Confman.Options
M.reload = function(opts)
    M.unload()
    M.setup(opts)
end

---refereshes the status sign for the given item in the give buffer
---@param item Modneo.Confman.ConfItem
---@param buf integer
M.refresh = function(item, buf)
    if item.enabled then
        vim.fn.sign_place(
            item.line_number,
            M.group,
            M.signs.config,
            buf,
            { lnum = item.line_number }
        )
        return
    end
    vim.fn.sign_unplace(M.group, { buffer = buf, id = item.line_number })
end

return M
