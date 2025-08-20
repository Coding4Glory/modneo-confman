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

    vim.api.nvim_set_option_value("modifiable", false, { scope = "local", buf = bufid })
    vim.api.nvim_set_option_value("cursorline", true, { scope = "local", buf = bufid })

    return bufid
end

---creates a floating window for the given buffer
---@type function
---@param buf integer buffer to show as floating
---@param bindings table? keybindings in form of `{ {lhs}, {rhs}, {desc} }`.
M.show_floating = function(buf, bindings)
    local float_size = M.get_window_dimensions(buf)

    local win_opts = {
        relative = 'editor',
        width = float_size.width(),
        height = float_size.hight(),
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
    vim.api.nvim_buf_set_keymap(
        buf,
        'n',
        'q',
        '<cmd>bw<CR>',
        { desc = 'close', noremap = true }
    )
    for _, kb in ipairs(bindings or {}) do
        vim.keymap.set(
            'n',
            kb[1],
            kb[2],
            { buffer = buf, desc = kb[3] or '' }
        )
    end
end

return M

-- vim: set et ts=4 sw=4 tw=78:
