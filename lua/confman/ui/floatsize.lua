---@type function
---gets the number of columns in the longest line
---@param buf integer buffer number
---@param line_count integer? number of lines in the buffer, will be determined if not provided
---@return integer the column count taken from the longest line
local function longest_line(buf, line_count)
    line_count = line_count or vim.api.nvim_buf_line_count(buf)
    local longest = 0
    for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 1, line_count, true)) do
        local current = string.len(l)
        longest = (current > longest and current or longest)
    end
    return longest
end

---@class FloatSize
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

---@type function
---gets the hight for the floating window
---@return integer
M.height = function()
    local max_height = M.ui_height - (M.y_border * 2)
    if M.content_height > max_height then
        return max_height
    end
    return M.content_height
end

---@type function
---gets the hight for the floating window
---@return integer
M.width = function()
    local max_width = M.ui_width - (M.x_border * 2)
    if M.content_width > max_width then
        return max_width
    end
    return M.content_width
end

---@type function
---gets the start row for the floating window
---@return integer
M.row = function()
    return (M.ui_height/2) - (M.height()/2)
end

---@type function
---gets the start col for the floating window
---@return integer
M.col = function()
    return (M.ui_width/2) - (M.width()/2)
end

---@class FloatSizeFabric
return {

    ---@type function
    ---creates a new FloatSize table
    ---@param buf integer the buffer to show as floating
    ---@return FloatSize
    new = function(buf)
        local vim_ui = vim.api.nvim_list_uis()[1]
        local line_count = vim.api.nvim_buf_line_count(buf)

        return vim.tbl_extend('force', M, {
            ui_width = vim_ui.width,
            ui_height = vim_ui.height,
            content_height = line_count,
            content_width = longest_line(buf, line_count)
        })
    end

}

