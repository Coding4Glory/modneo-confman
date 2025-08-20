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

---initialzes the renderer with the configuration
M.init = function()
    M.options = require'confman.config'.options
    return M
end

---prints the given plugins
---@param plugins table
---@param settings ConfmanOptions
M.print_plugin_files = function(plugins, settings)
    local enabled = plugins[settings.link_dir]
    for c, pl in pairs(plugins) do
        vim.print(c)
        for _, p in ipairs(pl) do
            vim.print('- ' .. vim.fs.basename(p) .. mark_enabled(p, enabled))
        end
    end
end

---renders the items to the buffer with the given id and sets the line numbers
---@param items table
---@param buf integer buffer to write to
---@return table
M.to_buf = function(items, buf)
    local line_counter = 1
    for c, pl in pairs(items) do
        local last_line = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, last_line, last_line + 1, false, { c })
        line_counter = line_counter + 1
        for _, p in ipairs(pl) do
            local line = string.format('- %s%s', p.name, p.enabled and ' *' or '')
            vim.api.nvim_buf_set_lines(buf, last_line, last_line + 1, false, { line })
            p.line_number = line_counter
            line_counter = line_counter + 1
        end
    end
end

return M
