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

local config = require('modneo-confman.config')

---renames the file
---@param item Modneo.ConfmanConfItem the item to rename
---@param new_basename string the new basename
local function rename(item, new_basename)
    local new_path = vim.fs.joinpath(item.realpath, new_basename)
    vim.uv.fs_rename(item.realpath, new_path)
end

---strips the suffix if existing
---@param item Modneo.ConfmanConfItem
---@return string?
local function get_enabled_name(item)
    local new_name = vim.fs
        .basename(item.realpath)
        :match('(.*)' .. config.options.disabled_suffix)

    if new_name == nil or new_name == '' then
        -- appearently not disabled - return current name to prevent damage
        return vim.fs.basename(item.realpath)
    end
end

---@param item Modneo.ConfmanConfItem
---@return string
local function get_disabled_name(item)
    return vim.fs.basename(item.realpath) .. config.options.disabled_suffix
end

---@type Modneo.Confman.Core.Strategy
return {
    enable_conf = function(item, _)
        local new_name = get_enabled_name(item)
        if new_name == nil then
            error('could not enable ' .. item.name .. ' file might not exist anymore')
        end
        rename(item, new_name)
        item.enabled = true
    end,

    disable_conf = function(item, _)
        local new_name = get_disabled_name(item)
        rename(item, new_name)
        item.enabled = false
    end,
}
