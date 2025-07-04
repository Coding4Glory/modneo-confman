---@class TinyConfmanConfig
local M = {}

---@class TinyConfmanSettings
---@field plugin_dir string the directory (within lua) 
---where the plugins configurations are located defaults to plugins
---@field link_dir string name of the directory to create the symlinks
---the same directory has to be set in lazy, will be created within plugin_dir
local defaults = {
    plugin_dir = 'plugins',
    link_dir = 'enabled',
}

---@type TinyConfmanSettings
M.settings = defaults

---@param args TinyConfmanSettings?
M.setup = function(args)
    M.settings = vim.tbl_deep_extend('force', M.settings, args or {})
    return M.settings
end

return M
