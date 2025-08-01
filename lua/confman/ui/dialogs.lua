---@class ConfmanDialogs
local M = {}

---@type function
---gets a table
---@return FloatSize
M.get_window_dimensions = function(buf)
    return require("tiny-core.ui.floatsize").new(buf)
end

M.add_close_binding = function(buf)
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bw<CR>", { desc = "close" })
end

---@type function
---creates a floating window for the given buffer
---@param buf integer buffer to show as floating
---@param bindings table? keybindings in form of `{ {lhs}, {rhs}, {desc} }`.
M.show_floating = function(buf, bindings)
    local vim_ui = vim.api.nvim_list_uis()[1]
    local float_size = M.get_window_dimensions(buf)
    print(vim.inspect(float_size))

    local win_opts = {
        relative = "editor",
        width = float_size.width(),
        height = float_size.hight(),
        col = float_size.col(),
        row = float_size.row(),
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "cursorline", true)
    M.add_close_binding(buf)

    for _, kb in ipairs(bindings or {}) do
        vim.keymap.set("n", kb[1], kb[2], { buffer = buf, desc = kb[3] or "" })
    end
end

return M

