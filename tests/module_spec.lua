local config = require('confman.config')
local core = require('confman.core')
local uv = (vim.uv or vim.loop)
local fixture_settings = config.init({
    config_dir = uv.cwd(),
    plugin_dir = 'tests/fixture',
})
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

describe('check pretest conditions', function()
    it('fixture exists', function()
        assert.truthy(vim.fn.isdirectory(vim.fs.joinpath(uv.cwd(), fixture_settings.plugin_dir)))
        assert.truthy(vim.fn.isdirectory(vim.fs.joinpath(uv.cwd(), fixture_settings.plugin_dir, 'cat_one')))
        assert.truthy(vim.fn.isdirectory(vim.fs.joinpath(uv.cwd(), fixture_settings.plugin_dir, 'cat_two')))
        assert.truthy(vim.fn.isdirectory(vim.fs.joinpath(uv.cwd(), fixture_settings.plugin_dir, 'enabled')))
    end)
    it ('assertion helpers correct', function() 
        assert.is_equal(2, count_categories({ one = {}, two = {} }))
        assert.is_equal(3, count_configs({ one = { '', '' }, two = { '' }, three = nil }))
    end)
end)

describe('test plugin functions:', function()
    it('gets a table with all plugins', function()
        local sut = core.setup(fixture_settings)
        local all_plugins = sut.list_available()
        assert.is_table(all_plugins)
        assert.is_equal(3, count_categories(all_plugins))
        assert.is_equal(3, count_configs(all_plugins))
    end)

    it('gets a table with enabled plugins', function()
        local sut = core.setup(fixture_settings)
        local enabled_plugins = sut.list_enabled()
        assert.is_table(enabled_plugins)
        assert.is_equal(1, count_categories(enabled_plugins))
        assert.is_equal(0, count_configs(enabled_plugins))
    end)

    -- it('enables a config', function()
    --     local sut = core.setup(fixture_settings)
    --     local opt =  { args = 'cat_one/mode_one' }
    --     sut.enable(opt)
    --     assert.truthy(uv.fs_stat(vim.fs.joinpath(
    --         uv.cwd(),
    --         fixture_settings.plugin_dir,
    --         fixture_settings.link_dir
    --     )))
    -- end)
end)

