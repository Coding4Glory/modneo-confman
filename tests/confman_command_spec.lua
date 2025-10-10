local settings = {
    config_root = (vim.uv or vim.loop).cwd(),
    plugin_lib = 'tests/fixture/rw',
    link_dir = 'enabled'
}
local core = require('modneo-confman').setup(settings)

describe('modneo-confman commands ', function()
    it('ConfmanEnable', function()
        vim.cmd('ConfmanEnable cat_one/mod_one')
        local found = core.get_item('cat_one', 'mod_one')
        assert.not_nil(found)
        ---@diagnostic disable-next-line
        assert.is_true(found.enabled)
    end)

    it('ConfmanDisable', function()
        core.enable('cat_two', 'mod_four.lua')
        vim.cmd('ConfmanDisable cat_two/mod_four')
        local found = core.get_item('cat_two', 'mod_four')
        assert.not_nil(found)
        ---@diagnostic disable-next-line
        assert.is_false(found.enabled)
    end)
end)

-- vim: set et ts=4 sw=4 tw=0 filetype=lua:
