local uv = (vim.uv or vim.loop)
local readonly_settings = {
    config_root = uv.cwd(),
    plugin_lib = 'tests/fixture/ro',
}
local readwrite_settings = {
    config_root = uv.cwd(),
    plugin_lib = 'tests/fixture/ro',
}

describe('confitem factory ', function()
    it('create new from path', function()
        local core = require('modneo-confman').setup(readonly_settings)
        local path = vim.fs.joinpath(
            uv.cwd(),
            'tests',
            'fixture',
            'ro',
            'cat_one',
            'mod_one.lua'
        )
        local sut = core.item_factory
        local result = sut.new(path)
        assert.is_equal(path, result.abspath)
        assert.is_equal(path, result.realpath)
        assert.is_false(result.enabled)
        assert.is_equal('cat_one', result.category)
        assert.is_equal('mod_one.lua', result.name)
    end)

    if not vim.startswith(uv.os_uname().sysname, 'Windows') then
        it('create from link', function()
            local core = require('modneo-confman').setup(readwrite_settings)
            local link_path = vim.fs.joinpath(
                uv.cwd(),
                'tests',
                'fixture',
                'rw',
                'enabled',
                'cat_one-mod_one.lua'
            )
            assert(vim.startswith(link_path, core.options.config_root))
            local test_file = vim.fs.joinpath(
                uv.cwd(),
                'tests',
                'fixture',
                'rw',
                'cat_one',
                'mod_one.lua'
            )
            uv.fs_symlink(test_file, link_path)
            local sut = core.item_factory
            local result = sut.new(link_path)
            assert.not_nil(result)
            assert.is_equal(link_path, result.abspath)
            assert.is_equal(test_file, result.realpath)
            assert.is_true(result.enabled)
            assert.is_equal('cat_one', result.category)
            assert.is_equal('mod_one.lua', result.name)
            uv.fs_unlink(link_path)
        end)
    end
end)

-- vim: set et ts=4 sw=4 tw=0 filetype=lua:
