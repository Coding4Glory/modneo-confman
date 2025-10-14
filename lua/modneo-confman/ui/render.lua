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

---@param item Modneo.Confman.ConfItem
---@return string
local function format_item(item)
    return fmt_ln(item.name, item.enabled)
end

---@return string[]
local function sorted_categories(list)
    local categories = {}
    for c, _ in pairs(list) do
        table.insert(categories, c)
    end
    table.sort(categories)
    return categories
end

local signs = require'modneo-confman.ui.signs'

---initialzes the renderer with the configuration
M.init = function()
    M.options = require('modneo-confman.config').options
    return M
end

---prints the given plugins.
---@param plugins table a table of th form { 'cat' = { 'mod', ... }, ... }
M.print_plugin_files = function(plugins)
    local categories = sorted_categories(plugins)
    for i, c in ipairs(categories) do
        vim.print(c)
        for _, p in ipairs(plugins[c]) do
            if type(p) == 'string' then
                vim.print(format_fullpath(p))
            else
                vim.print(format_item(p))
            end
        end
    end
end

---renders the items to the buffer with the given id and sets the line numbers
---@param plugins table a list of ConfmanConfItem instances
---@param buf integer buffer to write to
M.to_buf = function(plugins, buf)
    if vim.api.nvim_buf_line_count(buf) > 1 then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '' })
        vim.fn.sign_unplace(signs.group, { buf = buf })
    end

    vim.api.nvim_buf_set_lines(
        buf,
        -2,
        -1,
        false,
        { 'Usage: [e]nable | [d]isable | [q]uit', '' }
    )
    local line_counter = vim.api.nvim_buf_line_count(buf)
    local categories = sorted_categories(plugins)
    local is_autoload = require('modneo-confman.config').is_autoload

    for _, c in ipairs(categories) do
        vim.api.nvim_buf_set_lines(buf, -2, -1, false, { c, '' })
        vim.fn.sign_place(
            line_counter,
            signs.group,
            is_autoload(c) and signs.names.autoload or signs.names.category,
            buf,
            { lnum = line_counter }
        )
        line_counter = line_counter + 1
        for _, p in ipairs(plugins[c]) do
            vim.api.nvim_buf_set_lines(
                buf,
                -2,
                -1,
                false,
                { '- ' .. p.name, '' }
            )
            p.line_number = line_counter
            if p.enabled then
                vim.fn.sign_place(
                    line_counter,
                    signs.group,
                    signs.names.config,
                    buf,
                    { lnum = line_counter }
                )
            end
            line_counter = line_counter + 1
        end
    end
end

return M
