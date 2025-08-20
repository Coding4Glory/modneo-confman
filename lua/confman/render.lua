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

local M = {}

---returns a marker to append if the plugin is enabled
---@param plugin string
---@param enabled table
---@return string
local function mark_enabled(plugin, enabled)
    for _, p in ipairs(enabled or {}) do
        if p == plugin then return ' *' end
    end
    return ''
end


---prints the given plugins
---@param plugins table
---@param settings ConfmanOptions
M.list_plugins = function(plugins, settings)
    local enabled = plugins[settings.link_dir]
    for c, pl in pairs(plugins) do
        vim.print(c)
        for _, p in ipairs(pl) do
            vim.print('- ' .. vim.fs.basename(p) .. mark_enabled(p, enabled))
        end
    end
end

return M
