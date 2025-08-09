local M = {}

---returns a marker to append if the plugin is enabled
---@param plugin string
---@param enabled table
---@return string
local function mark_enabled(plugin, enabled)
    for _, p in ipairs(enabled or {}) do
        if p == plugin then return ' *' end
    end
    return ''
end


---prints the given plugins
---@param plugins table
---@param settings TinyConfmanSettings
M.list_plugins = function(plugins, settings)
    local enabled = plugins[settings.link_dir]
    for c, pl in pairs(plugins) do
        vim.print(c)
        for _, p in ipairs(pl) do
            vim.print('- ' .. vim.fs.basename(p) .. mark_enabled(p, enabled))
        end
    end
end

return M
