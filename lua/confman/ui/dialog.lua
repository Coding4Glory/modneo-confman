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
    return nil
end

---@return ConfmanConfItem?
local function get_selected(plugins, win)
    local _, row, _, _, _ = unpack(vim.fn.getcurpos(win))
    return get_by_line(plugins, row)
end

---@class ConfmanDialogs
local M = {}

---gets a table
---@type function
---@return FloatSize
M.get_window_dimensions = function(buf)
    return require('confman.ui.floatsize').new(buf)
end

---@return integer|nil
M.new_buffer = function()
    local bufid = vim.api.nvim_create_buf(false, true)
    if bufid == 0 then
        vim.notify('could not create buffer for UI', vim.log.levels.ERROR)
        return nil
    end

    vim.api.nvim_set_option_value(
        'modifiable',
        true,
        { scope = 'local', buf = bufid }
    )
    return bufid
end


M.close_dialog = function(win, buf)
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
end

---creates a floating window for the given buffer
---@type function
---@param buf integer buffer to show as floating
---@param plugins table
M.show_plugins = function(plugins)
    local buf = M.new_buffer()
    if buf == nil then
        return
    end

    require('confman.ui.render').init().to_buf(plugins, buf)
    vim.api.nvim_set_option_value(
        'modifiable',
        false,
        { scope = 'local', buf = buf }
    )

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
        'cursorline',
        true,
        { scope = 'local', win = win }
    )

    vim.api.nvim_set_option_value(
        'number',
        false,
        { scope = 'local', win = win }
    )
    vim.api.nvim_set_option_value(
        'relativenumber',
        false,
        { scope = 'local', win = win }
    )
    vim.keymap.set(
        'n',
        'q',
        function() M.close_dialog(win, buf) end,
        {
            desc = 'b' .. buf .. 'Confman: close',
            noremap = true,
            buffer = buf,
        }
    )
    vim.keymap.set('n', 't', function()
        local selected = get_selected(plugins, win)
        print(vim.inspect(selected))
    end, {
        desc = 'b' .. buf .. ' Confman: enable',
        noremap = true,
        buffer = buf,
    })
    vim.keymap.set('n', 'e', function()
        local to_enable = get_selected(plugins, win)
        if to_enable ~= nil then
            to_enable.enable()
        end
    end, {
        desc = 'b' .. buf .. ' Confman: enable',
        noremap = true,
        buffer = buf,
    })
    vim.keymap.set('n', 'E', function()
        local to_enable = get_selected(plugins, win)
        if to_enable ~= nil then
            to_enable.enable(true)
        end
    end, {
        desc = 'b' .. buf .. ' Confman: enable',
        noremap = true,
        buffer = buf,
    })
    vim.keymap.set('n', 'd', function()
        local to_disable = get_selected(plugins)
        if to_disable ~= nil then
            to_disable.disable()
        end
    end, {
        desc = 'b' .. buf .. ' Confman: disable',
        noremap = true,
        buffer = buf,
    })
    vim.api.nvim_set_current_win(win)
end

return M

-- vim: set et ts=4 sw=4 tw=78:
