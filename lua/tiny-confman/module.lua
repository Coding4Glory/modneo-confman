---@class TinyConfmanModule
local M = {}

---@param settings TinyConfmanSettings
---@return string
local function get_plugin_dir(settings)
    return vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', settings.plugin_dir)
end

---Gets the files in base path maching the given filter.
---If no filter is given only files or directories not containing dots will be returned.
---@param basepath any
---@param filter any
---@return string[]
local function get_files(basepath, filter)
    filter = filter or '/*[^.]'
    local path = basepath .. filter
    return vim.split(vim.fn.glob(path), '\n', { trimempty = true })
end

---@param settings TinyConfmanSettings
---@param category string? Optional: the category to show
---@return table
local function get_plugins(settings, category)
    local plugin_path = get_plugin_dir(settings)
    local plugins = {}
    for _, folder in ipairs(get_files(plugin_path)) do
        if category ~= nil and category ~= folder then
            goto continue
        end
        local cat_key = vim.fs.basename(folder)
        plugins[cat_key] = get_files(vim.fs.joinpath(plugin_path, cat_key), '/*.lua')
        ::continue::
    end
    return plugins
end

---@type TinyConfmanSettings
---@private
M.config = {}

---@type function
---lists all available plugins
M.list_available = function()
    print(vim.inspect(get_plugins(M.config)))
end

---@type function
---lists the enabled plugins
M.list_enabled = function()
    print(vim.inspect(get_plugins(M.config, M.config.link_dir)))
end

---@type function
---enables the given plugin
---@param opts vim.api.keyset.create_user_command.command_args a category/name combination
M.enable = function(opts)
    local src_file = vim.fs.joinpath(get_plugin_dir(M.config), opts.args)
    local uv = (vim.uv or vim.loop)
    if not uv.fs_stat(src_file) then
        vim.api.nvim_err_writeln('Plugin file for ' .. name .. ' not found')
        return
    end
    local dst_file = vim.fs.joinpath(get_plugin_dir(M.config), M.config.link_dir)
    if uv.fs_stat(dst_file) then
        if not opts.bang then
            print('Plugin already enabled', vim.log.levels.INFO)
            return
        end
        uv.fs_unlink(dst_file)
    end

    uv.fs_symlink(src_file, dst_file)
end

---@type function
---disables the given plugin
---@param opts vim.api.keyset.create_user_command.command_args a category/name combination
M.disable = function(opts)
    local parts = vim.split(opts.args, '/', { trimempty = true })
    local link_file = vim.fs.joinpath(get_plugin_dir(M.config), M.config.link_dir, parts[1])
    local uv = (vim.uv or vim.loop)
    if uv.fs_stat(link_file) then
        uv.fs_unlink(link_file)
    end
end

---@type function
---call on require to apply settings
---@param settings TinyConfmanSettings the settings to apply
---@return TinyConfmanModule
M.init = function(settings)
    M.config = settings or require('tiny-confman.config').settings
    return M
end

return M
