---@class TinyConfmanConfig
local M = {}

---@class TinyConfmanSettings
--@field link_dir string name of the directory to create the symlinks
---the same directory has to be set in lazy, will be created within plugin_dir
local defaults = {
    ---@type string 
    ---the directory (within lua) where the plugins configurations are located defaults to plugins
    plugin_dir = 'plugins',
    ---@type string
    ---the directory where links to enabled plugins shall be stored
    link_dir = 'enabled',
    ---@type string
    ---the directory separation character
    dir_separator = ((vim.uv or vim.loop).os_uname().sysname == 'Linux' and '/' or '\\')
}

---@type TinyConfmanSettings
M.settings = defaults

---@param args TinyConfmanSettings?
M.setup = function(args)
    M.settings = vim.tbl_deep_extend('force', M.settings, args or {})
    return M.settings
end

return M
