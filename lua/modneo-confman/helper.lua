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

---returns the larger table first
---@param first string[]
---@param second string[]
---@return string[]
---@return string[]
local function by_size(first, second)
    if #first > #second then
        return first, second
    end
    return second, first
end

---merges to tables
---@param first string[]
---@param second string[]
---@return string[]
local function merge_optimized(first, second)
    local larger, smaller = by_size(first, second)
    local result = vim.tbl_deep_extend('force', {}, larger)

    for _, x in ipairs(smaller) do
        if not vim.tbl_contains(larger, x) then
            table.insert(result, x)
        end
    end
    return result
end

---@class Modneo.Confman.Helper
local M = {}

---merges the given lists into a new one
---@param first string[]
---@param second string[]
---@return string[]
M.tbl_merge = function(first, second)
    return merge_optimized(first, second)
end

return M

