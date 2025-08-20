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

---@class ConfmanDialogs
local M = {}

-- local F = require("confman.ui.floatsize")

---@type function
---gets a table
---@return FloatSize
M.get_window_dimensions = function(buf)
    -- return F.new(buf)
    return require('confman.ui.floatsize').new(buf)
end

M.add_close_binding = function(buf)
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bw<CR>", { desc = "close" })
end

---@type function
---creates a floating window for the given buffer
---@param buf integer buffer to show as floating
---@param bindings table? keybindings in form of `{ {lhs}, {rhs}, {desc} }`.
M.show_floating = function(buf, bindings)
    local float_size = M.get_window_dimensions(buf)

    local win_opts = {
        relative = "editor",
        width = float_size.width(),
        height = float_size.hight(),
        col = float_size.col(),
        row = float_size.row(),
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.api.nvim_set_option_value("modifiable", false, { scope = "local", buf = buf })
    vim.api.nvim_set_option_value("cursorline", true, { scope = "local", buf = buf })
    M.add_close_binding(buf)

    for _, kb in ipairs(bindings or {}) do
        vim.keymap.set("n", kb[1], kb[2], { buffer = buf, desc = kb[3] or "" })
    end
end

return M

