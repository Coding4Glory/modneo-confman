local M = {}

---prints the given plugins
---@param plugins table
M.list_plugins = function(plugins)
    for c, pl in pairs(plugins) do
        vim.print(c)
        for _, p in ipairs(pl) do
            vim.print('- ' .. vim.fs.basename(p))
        end
    end
end

return M
