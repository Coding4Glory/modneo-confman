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

---@return ConfmanConfItem?
local function get_by_line(plugins, lineno)
    for _, pl in pairs(plugins) do
        for _, p in ipairs(pl) do
            if p.line_number == lineno then
                return p
            end
        end
    end
end

---@class ConfmanDialogs
local M = {}

---gets a table
---@type function
---@return FloatSize
M.get_window_dimensions = function(buf)
    -- return F.new(buf)
    return require('confman.ui.floatsize').new(buf)
end

M.new_buffer = function()
    local bufid = vim.api.nvim_create_buf(false, true)
    if bufid == 0 then
        vim.notify('could not create buffer for UI', vim.log.levels.ERROR)
        return nil
    end

    vim.api.nvim_set_option_value(
        'modifiable',
        false,
        { scope = 'local', buf = bufid }
    )
    vim.api.nvim_set_option_value(
        'cursorline',
        true,
        { scope = 'local', buf = bufid }
    )

    return bufid
end

---creates a floating window for the given buffer
---@type function
---@param buf integer buffer to show as floating
---@param plugins table
M.show_plugins = function(plugins)
    local buf = M.new_buffer()
    require('confman.ui.render').init().to_buf(plugins, buf)
    local float_size = M.get_window_dimensions(buf)

    local win_opts = {
        relative = 'editor',
        width = float_size.width(),
        height = float_size.height(),
        col = float_size.col(),
        row = float_size.row(),
        border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)

    vim.api.nvim_set_option_value(
        'number',
        false,
        { scope = 'local', buf = buf }
    )
    vim.api.nvim_set_option_value(
        'relativenumber',
        false,
        { scope = 'local', buf = buf }
    )
    vim.keymap.set(
        'n',
        'q',
        '<cmd>bw<CR>',
        { desc = 'b' .. buf .. 'Confman: close', noremap = true, buffer = buf }
    )
    vim.keymap.set(
        'n',
        'e',
        function()
            local lineno = vim.fn.getpos('.')
            local to_enable = get_by_line(plugins, lineno)
            if to_enable ~= nil then
                to_enable.enable()
            end
        end,
        {
            desc = 'b' .. buf .. ' Confman: enable',
            noremap = true,
            buffer = buf,
        }
    )
    vim.keymap.set(
        'n',
        'E',
        function()
            local lineno = vim.fn.getpos('.')
            local to_enable = get_by_line(plugins, lineno)
            if to_enable ~= nil then
                to_enable.enable(true)
            end
        end,
        {
            desc = 'b' .. buf .. ' Confman: enable',
            noremap = true,
            buffer = buf,
        }
    )
    vim.keymap.set(
        'n',
        'd',
        function()
            local lineno = vim.fn.getpos('.')
            local to_disable = get_by_line(plugins, lineno)
            if to_disable ~= nil then
                to_disable.disable()
            end
        end,
        {
            desc = 'b' .. buf .. ' Confman: disable',
            noremap = true,
            buffer = buf,
        }
    )
end

return M

-- vim: set et ts=4 sw=4 tw=78:
