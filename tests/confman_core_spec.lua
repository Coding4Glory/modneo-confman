local plugin = require('modneo-confman')
local uv = (vim.uv or vim.loop)
local readonly_settings = {
    config_root = uv.cwd(),
    plugin_lib = 'tests/fixture/ro',
}
local symlink_settings = {
    config_root = uv.cwd(),
    plugin_lib = 'tests/fixture/link',
    strategy = 'symlink',
}
local rename_settings = {
    config_root = uv.cwd(),
    plugin_lib = 'tests/fixture/rename',
    strategy = 'rename',
}

---@type Modneo.Confman.Core.Strategy
local no_autoload = {
    disable_conf = function(_) end,
    enable_conf = function(_, _) end,
    get_configs = function(_) return {} end,
    get_enabled = function (_) return {} end,
    find = function(_) return nil end,
    is_enabled = function(_) return false end,
    name = function() return 'au_mock' end,
}

local get_sut = function (opts)
    local sut = plugin.setup(opts)
    sut.autoload = no_autoload
    return sut
end

local function count_configs(t)
    local i = 0
    for _, x in pairs(t) do
        if x == nil then
            goto continue
        end
        for _, _ in ipairs(x) do
            i = i + 1
        end
        ::continue::
    end
    return i
end

local function count_categories(t)
    local i = 0
    for _, _ in pairs(t) do
        i = i + 1
    end
    return i
end
require('luassert')

describe('check pretest conditions ', function()
    it('fixture exists', function()
        assert.truthy(vim.fn.isdirectory(vim.fs.joinpath(uv.cwd(), readonly_settings.plugin_lib)))
        assert.truthy(vim.fn.isdirectory(vim.fs.joinpath(uv.cwd(), readonly_settings.plugin_lib, 'cat_one')))
        assert.truthy(vim.fn.isdirectory(vim.fs.joinpath(uv.cwd(), readonly_settings.plugin_lib, 'cat_two')))
        assert.truthy(vim.fn.isdirectory(vim.fs.joinpath(uv.cwd(), readonly_settings.plugin_lib, 'enabled')))
    end)
    it ('assertion helpers correct', function()
        assert.is_equal(2, count_categories({ one = {}, two = {} }))
        assert.is_equal(3, count_configs({ one = { {}, {} }, two = { {} }, three = nil }))
    end)
end)

describe('symlink strategy ', function()
    describe('test listing:', function()
        it('all plugins', function()
            local sut = get_sut(readonly_settings)
            local all_plugins = sut.list_available()
            assert.is_table(all_plugins)
            assert.is_equal(2, count_categories(all_plugins))
            assert.is_equal(4, count_configs(all_plugins))
        end)

        it('enabled plugins', function()
            local sut = get_sut(readonly_settings)
            local enabled_plugins = sut.list_enabled()
            assert.is_table(enabled_plugins)
            assert.is_equal(0, count_categories(enabled_plugins))
            assert.is_equal(0, count_configs(enabled_plugins))
        end)

    end)

    describe('test getting single:', function()
        it('with simple name', function()
            local sut = get_sut(readonly_settings)
            assert.not_nil(sut.get_item('cat_one', 'mod_one'))
        end)
        it('with full name', function()
            local sut = get_sut(readonly_settings)
            assert.not_nil(sut.get_item('cat_one', 'mod_two.lua'))
        end)
        it('nothing to find', function()
            local sut = get_sut(readonly_settings)
            assert.is_nil(sut.get_item('not', 'existing'))
        end)
    end)

    describe('test management', function()
        it('enables a plugin', function ()
            local sut = get_sut(symlink_settings)
            sut.enable('cat_one', 'mod_one')
            local link_pattern = vim.fs.joinpath(uv.cwd(), symlink_settings.plugin_lib, 'enabled', '*mod_one*')
            local result = vim.fn.glob(link_pattern, false, true, false)
            assert.is_equal(1, #result)
            vim.fs.rm(result[1])
        end)
        it('disables a plugin', function ()
            local sut = get_sut(symlink_settings)
            sut.enable('cat_two', 'mod_three.lua')
            local link_pattern = vim.fs.joinpath(uv.cwd(), symlink_settings.plugin_lib, 'enabled', '*mod_three*')
            local link_path = vim.fn.glob(link_pattern, false, true, false)
            assert.is_equal(1, #link_path)
            sut.disable('cat_two', 'mod_three')

            assert.is_equal(0, vim.tbl_count(vim.fn.glob(link_pattern, false, true, true)))
        end)
    end)
end)

describe('rename strategy ', function()
    print(uv.cwd())
    describe('test listing:', function()
        it('all plugins', function()
            local sut = get_sut(rename_settings)
            local all_plugins = sut.list_available()
            assert.is_table(all_plugins)
            assert.is_equal(2, count_categories(all_plugins))
            assert.is_equal(4, count_configs(all_plugins))
        end)

        it('enabled plugins', function()
            local sut = get_sut(rename_settings)
            local enabled_plugins = sut.list_enabled()
            assert.is_table(enabled_plugins)
            assert.is_equal(0, count_categories(enabled_plugins))
            assert.is_equal(0, count_configs(enabled_plugins))
        end)

    end)

    describe('test getting single:', function()
        readonly_settings.strategy = 'rename'
        it('with simple name', function()
            local sut = get_sut(readonly_settings)
            assert.not_nil(sut.get_item('cat_one', 'mod_one'))
        end)
        it('with full name', function()
            local sut = get_sut(readonly_settings)
            assert.not_nil(sut.get_item('cat_one', 'mod_two.lua'))
        end)
        it('nothing to find', function()
            local sut = get_sut(readonly_settings)
            assert.is_nil(sut.get_item('not', 'existing'))
        end)
    end)

    describe('test management', function()
        it('enables a plugin', function ()
            local on_name = vim.fs.joinpath(uv.cwd(), rename_settings.plugin_lib, 'cat_one', 'mod_two.lua')
            local sut = get_sut(rename_settings)
            sut.enable('cat_one', 'mod_two')
            assert.not_nil(uv.fs_stat(on_name))
            assert.is_nil(uv.fs_stat(on_name .. '.off'))
        end)
        it('disables a plugin', function ()
            local off_name = vim.fs.joinpath(uv.cwd(), rename_settings.plugin_lib, 'cat_two', 'mod_three.lua.off')
            uv.fs_rename(off_name, off_name:match('(.*).off$'))
            local sut = get_sut(rename_settings)
            sut.disable('cat_two', 'mod_three')
            assert.is_nil(uv.fs_stat(off_name:match('(.*).off$')))
            assert.not_nil(uv.fs_stat(off_name))
        end)
    end)
end)

-- vim: set et ts=4 sw=4 tw=0 filetype=lua:
