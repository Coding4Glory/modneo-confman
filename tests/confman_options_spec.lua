local uv = (vim.uv or vim.loop)
local readonly_settings = {
    config_root = uv.cwd(),
    plugin_lib = 'tests/fixture',
}
require('modneo-confman.config').setup(readonly_settings)

describe('test pattern building:', function()
    it('with full name', function()
        local sut = require('modneo-confman.config')
        assert.is_equal('file.lua', sut.get_file_pattern('file.lua'))
    end)
    it('with simple name', function()
        local sut = require('modneo-confman.config')
        assert.not_equal('file', sut.get_file_pattern('file'))
    end)
    it('without name', function()
        local sut = require('modneo-confman.config')
        local pattern = sut.get_file_pattern()
        assert.truthy(vim.startswith(pattern, '*'))
        assert.truthy(vim.endswith(pattern, sut.options.default_filter))
    end)
end)


