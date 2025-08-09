---@class TinyConfmanCore
local M = {}

---@type TinyConfmanSettings
---@private
M.config = {}

---@param settings TinyConfmanSettings
---@return string
local function get_plugin_dir(settings)
    return vim.fs.joinpath(vim.fn.stdpath('config'), 'lua', settings.plugin_dir)
end

---Gets the files in basepath maching the given filter.
---If no filter is given only files or directories not containing dots will be returned.
---@param basepath any
---@param filter any
---@return table
local function get_files(basepath, filter, all_links)
    all_links = all_links or false
    filter = filter or '*.[lv][iu][am]'
    local path = vim.fs.joinpath(basepath, filter)
    return vim.fn.glob(path, false, true, all_links)
end

---@param settings TinyConfmanSettings
---@param category string? Optional: the category to show
---@return table
local function get_plugins(settings, category)
    local plugin_path = get_plugin_dir(settings)
    local plugins = {}
    for folder, type in vim.fs.dir(plugin_path) do
        if type ~= 'directory' then goto continue end
        if category ~= nil and category ~= folder then goto continue end

        local cat_key = vim.fs.basename(folder)
        plugins[cat_key] = get_files(vim.fs.joinpath(plugin_path, cat_key), nil, category == settings.link_dir)

        ::continue::
    end
    return plugins
end

---prints the given plugins
---@param plugins table
local function print_plugins(plugins)
    for c, pl in pairs(plugins) do
        print(c)
        for _, p in ipairs(pl) do
            vim.print(vim.fs.basename(p))
        end
    end
end

---@type function
---lists all available plugins
M.list_available = function()
    print_plugins(get_plugins(M.config))
end

---@type function
---lists the enabled plugins
M.list_enabled = function()
    print_plugins(get_plugins(M.config, M.config.link_dir))
end


---enables the given plugin
---@type function
---@param opts vim.api.keyset.create_user_command.command_args a category/name combination
M.enable = function(opts)
    local uv = (vim.uv or vim.loop)
    for cat, mod in string.gmatch(opts.args, '([%._%-%w]+)[/\\]([%._%-%w]+)') do
        local modpath = vim.fs.joinpath(get_plugin_dir(M.config), cat, mod)
        local src_file = vim.fs.joinpath(get_plugin_dir(M.config), opts.args)

        if not uv.fs_stat(src_file) then
            print('Plugin file for ' .. opts.args .. ' not found')
            return
        end
        local dst_file = vim.fs.joinpath(get_plugin_dir(M.config), M.config.link_dir)
        if uv.fs_stat(dst_file) then
            if not opts.bang then
                print('!! Plugin already enabled call TinyEnPlug! to recreate link')
                return
            end
            uv.fs_unlink(dst_file)
        end

        uv.fs_symlink(src_file, dst_file)
    end
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
---@return TinyConfmanCore
M.init = function(settings)
    M.config = settings or require('tiny-confman.config').settings
    return M
end

return M
