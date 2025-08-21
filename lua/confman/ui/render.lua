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

local function fmt_ln(name, enabled)
    return string.format('- %s%s', name, (enabled and ' *' or ''))
end

---@param path string
---@return string
local function format_fullpath(path, link_dir)
    local enabled = vim.fs.basename(vim.fs.dirname(path)) == link_dir
    return fmt_ln(vim.fs.basename(path), enabled)
end

---@param item ConfmanConfItem
---@return string
local function format_item(item)
    return fmt_ln(item.name, item.enabled)
end

---initialzes the renderer with the configuration
M.init = function()
    M.options = require'confman.config'.options
    return M
end

---prints the given plugins
---@param plugins table a table of th form { 'cat' = { 'mod', ... }, ... }
---@param settings ConfmanOptions
M.print_plugin_files = function(plugins, settings)
    for c, pl in pairs(plugins) do
        vim.print(c)
        for _, p in ipairs(pl) do
            if type(p) == 'string' then
                vim.print(format_fullpath(p))
            else
                vim.print(format_item(p))
            end

        end
    end
end

---renders the items to the buffer with the given id and sets the line numbers
---@param items table a list of ConfmanConfItem instances
---@param buf integer buffer to write to
---@return table
M.to_buf = function(items, buf)
    local line_counter = 1
    for c, pl in pairs(items) do
        vim.api.nvim_buf_set_lines(buf, -2, -1, false, { c, '' })
        line_counter = line_counter + 1
        for _, p in ipairs(pl) do
            vim.api.nvim_buf_set_lines(buf, -2, -1, false, { format_item(p), '' })
            p.line_number = line_counter
            line_counter = line_counter + 1
        end
    end
end

return M
