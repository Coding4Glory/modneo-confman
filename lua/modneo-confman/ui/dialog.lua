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

---Modneo.ConfmanConfItem?
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

---Modneo.ConfmanConfItem?
local function get_selected(plugins, win)
    local _, row, _, _, _ = unpack(vim.fn.getcurpos(win))
    return get_by_line(plugins, row)
end

---@class Modneo.ConfmanDialogs
local M = {}

---sets the plugins as new content of the given buffer
---@param plugins table
---@param buf integer
---@private
M.set_buffer_content = function(plugins, buf)
    vim.api.nvim_set_option_value(
        'modifiable',
        true,
        { scope = 'local', buf = buf }
    )

    M.render.to_buf(plugins, buf)

    vim.api.nvim_set_option_value(
        'modifiable',
        false,
        { scope = 'local', buf = buf }
    )
end

---refereshes the status sign for the given item
---@param item ConfmanConfItem
---@param buf integer
M.refresh_sign = function(item, buf)
    if item.enabled then
        vim.fn.sign_place(
            item.line_number,
            M.render.sign.group,
            M.render.sign.name,
            buf,
            { lnum = item.line_number }
        )
        return
    end
    vim.fn.sign_unplace(M.render.sign.group, { buffer = buf, id = item.line_number })
end

---gets the name of the dialog buffer
---@type string
---@private
M.dialog_name = 'ConfmanDialog'

---gets a table
---@type function
---@return FloatSize
M.get_window_dimensions = function(buf)
    return require('modneo-confman.ui.floatsize').new(buf)
end

---@return integer
M.get_buffer = function()
    local bufid = vim.fn.bufnr(M.dialog_name)
    if bufid > 0 then return bufid end

    bufid = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(bufid, M.dialog_name)
    return bufid
end

M.close_dialog = function(win, buf)
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
end

---@type table
---@private
M.border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' }

---creates a floating window for the given buffer
---@type function
---@param plugins table
M.show_plugins = function(plugins)
    M.core = require('modneo-confman.core')
    M.render = require('modneo-confman.ui.render').init()

    local buf = M.get_buffer()
    if buf == nil then
        return
    end

    M.set_buffer_content(plugins, buf)

    local float_size = M.get_window_dimensions(buf)


    local win = vim.api.nvim_open_win(buf, true, float_size.to_options(M.border))
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
    vim.api.nvim_set_option_value(
        'signcolumn',
        'yes:1',
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
    vim.keymap.set('n', 'e',
        function()
            local selected = get_selected(plugins, win)
            if selected ~= nil then
                if selected.enabled then return end
                M.core.enable_conf(selected)
                M.refresh_sign(selected, buf)
            end
        end,
        {
            desc = 'b' .. buf .. ' Confman: enable',
            noremap = true,
            buffer = buf,
        }
    )
    vim.keymap.set('n', 'E',
        function()
            local selected = get_selected(plugins, win)
            if selected ~= nil then
                M.core.enable_conf(selected, true)
                M.refresh_sign(selected, buf)
            end
        end,
        {
            desc = 'b' .. buf .. ' Confman: enable',
            noremap = true,
            buffer = buf,
        }
    )
    vim.keymap.set('n', 'd',
        function()
            local selected = get_selected(plugins)
            if selected ~= nil then
                if not selected.enabled then return end
                M.core.disable_conf(selected)
                M.refresh_sign(selected, buf)
            end
        end,
        {
            desc = 'b' .. buf .. ' Confman: disable',
            noremap = true,
            buffer = buf,
        }
    )
    vim.api.nvim_create_autocmd('VimResized',
        {
            buffer = buf,
            callback = function()
                float_size.on_resize()
                vim.api.nvim_win_set_config(win, float_size.to_options(M.border))
            end
        }
    )
    vim.api.nvim_set_current_win(win)
end

return M

-- vim: set et ts=4 sw=4 tw=78:
