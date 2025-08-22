local core = require('confman').setup({
    config_root = (vim.uv or vim.loop).cwd(),
    plugin_lib = 'tests/fixture_rw',
    link_dir = 'enabled'
})

describe('confman commands ', function()
    it('ConfmanEnable', function()
        vim.cmd('ConfmanEnable cat_one/mod_two')
        assert.not_nil((vim.uv or vim.loop).fs_stat(core.get_link_name('cat_one', 'mod_two.lua')))
        vim.fs.rm(core.get_link_name('cat_one', 'mod_two.lua'))
    end)
    it('ConfmanDisable', function()
        core.enable('cat_two', 'mod_four.lua')
        vim.cmd('ConfmanDisable cat_two/mod_four')
        assert.is_nil((vim.uv or vim.loop).fs_stat(core.get_link_name('cat_two', 'mod_four.lua')))
    end)
end)

-- vim: set et ts=4 sw=4 tw=0 filetype=lua:
