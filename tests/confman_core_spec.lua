local plugin = require('modneo-confman')
local uv = (vim.uv or vim.loop)
local readonly_settings = {
    config_root = uv.cwd(),
    plugin_lib = 'tests/fixture',
}
local readwrite_settings = {
    config_root = uv.cwd(),
    plugin_lib = 'tests/fixture_rw',
}

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

describe('core module ', function()
    describe('test pattern building:', function()
        it('with full name', function()
            local sut = plugin.setup(readonly_settings)
            assert.is_equal('file.lua', sut.get_file_pattern('file.lua'))
        end)
        it('with simple name', function()
            local sut = plugin.setup(readonly_settings)
            assert.not_equal('file', sut.get_file_pattern('file'))
        end)
        it('without name', function()
            local sut = plugin.setup(readonly_settings)
            local pattern = sut.get_file_pattern()
            assert.truthy(vim.startswith(pattern, '*'))
            assert.truthy(vim.endswith(pattern, sut.options.default_filter))
        end)
    end)

    describe('test listing:', function()
        it('all plugins', function()
            local sut = plugin.setup(readonly_settings)
            local all_plugins = sut.list_available()
            assert.is_table(all_plugins)
            assert.is_equal(2, count_categories(all_plugins))
            assert.is_equal(4, count_configs(all_plugins))
        end)

        it('enabled plugins', function()
            local sut = plugin.setup(readonly_settings)
            local enabled_plugins = sut.list_enabled()
            assert.is_table(enabled_plugins)
            assert.is_equal(0, count_categories(enabled_plugins))
            assert.is_equal(0, count_configs(enabled_plugins))
        end)

    end)

    describe('test getting single:', function()
        it('with simple name', function()
            local sut = plugin.setup(readonly_settings)
            assert.not_nil(sut.get_item('cat_one', 'mod_one'))
        end)
        it('with full name', function()
            local sut = plugin.setup(readonly_settings)
            assert.not_nil(sut.get_item('cat_one', 'mod_two.lua'))
        end)
        it('nothing to find', function()
            local sut = plugin.setup(readonly_settings)
            assert.is_nil(sut.get_item('not', 'existing'))
        end)
    end)

    describe('test management', function()
        it('enables a plugin', function ()
            local sut = plugin.setup(readwrite_settings)
            sut.enable('cat_one', 'mod_one')
            assert.not_nil((vim.uv or vim.loop).fs_stat(sut.get_link_name('cat_one', 'mod_one.lua')))
            vim.fs.rm(sut.get_link_name('cat_one', 'mod_one.lua'))
        end)
        it('disables a plugin', function ()
            local sut = plugin.setup(readwrite_settings)
            sut.enable('cat_two', 'mod_three.lua')
            sut.disable('cat_two', 'mod_three')
            assert.is_nil((vim.uv or vim.loop).fs_stat(sut.get_link_name('cat_two', 'mod_three.lua')))
        end)
    end)
end)

-- vim: set et ts=4 sw=4 tw=0 filetype=lua:
