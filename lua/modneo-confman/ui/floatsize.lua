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

---gets the number of columns in the longest line
---@param buf integer buffer number
---@return integer the column count taken from the longest line
local function window_width(buf)
    local longest = 0
    for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, true)) do
        local current = string.len(l)
        longest = (current > longest and current or longest)
    end
    return longest + 2 -- sign column and trailing column
end

local function side_length(min, max, content)
    if content > max then return max end
    if content < min then return min end
    return content
end

---@class Modneo.Confman.UI.FloatSize
---@field ui_width integer
---@field ui_height integer
---@field y_border integer minimum space above and below the window
---@field x_border integer minimum space beside the window
---@field content_height integer height of content
---@field content_width integer width of content
local M = {
    x_border = 10,
    y_border = 5,
}

---gets the hight for the floating window
---@param min integer|nil minimum height
---@return integer
M.height = function(min)
    local max_height = M.ui_height - (M.y_border * 2)
    return side_length(min or 3, max_height, M.content_height)
end

---gets the hight for the floating window
---@param min integer|nil
---@return integer
M.width = function(min)
    local max_width = M.ui_width - (M.x_border * 2)
    return side_length(min or 10, max_width, M.content_width)
end

---gets the start row for the floating window
---@return integer
M.row = function()
    return (M.ui_height/2) - (M.height()/2)
end

---gets the start col for the floating window
---@return integer
M.col = function()
    return (M.ui_width/2) - (M.width()/2)
end

---function to call when the UI get's resized, e. g. in a terminal window
M.on_resize = function()
    M.ui_width = vim.o.columns
    M.ui_height = vim.o.lines
end

---@param border table the list with border characters
---@return vim.api.keyset.win_config
M.to_options = function(border)
    ---@type vim.api.keyset.win_config
    return {
        relative = 'editor',
        width = M.width(),
        height = M.height(),
        col = M.col(),
        row = M.row(),
        border = border
    }
end

---initializes the table for a new buffer
---@return Modneo.Confman.UI.FloatSize
M.new = function(buf)
    local line_count = vim.api.nvim_buf_line_count(buf)
    M.ui_width = vim.o.columns
    M.ui_height = vim.o.lines
    M.content_height = line_count
    M.content_width = window_width(buf)
    return M
end

return M

