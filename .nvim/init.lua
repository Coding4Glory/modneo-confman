local function get_container_command()
    local engines = {
        'podman',
        'docker',
    }
    for _, e in ipairs(engines) do
        if vim.fn.executable(e) then
            return e
        end
    end
    return nil
end

local command = get_container_command()

if command ~= nil then
    vim.keymap.set('n', '<localleader>bd', function()
        vim.system({
            command,
            'run',
            '--rm',
            '-v',
            '.:/workspace',
            'panvimdoc:latest',
            '--project-name',
            'modneo-confman',
            '--input-file',
            'README.md',
            '--vim-version',
            'neovim-0.11',
            '--toc',
            'true',
            '--demojify',
            'true',
            '--dedup-subheadings',
            'true',
        }, {
            text = true,
        }, function(obj)
            if obj.code == 0 then
                print(obj.stdout)
            else
                print(obj.stderr)
            end
        end)
    end, { desc = '[b]uild [d]ocumentation' })
end

vim.keymap.set('n', '<localleader>t', function()
    local uv = (vim.uv or vim.loop)
    if
        -- this shoud only return a result when with cwd set to project
        -- otherwise this file should not have been loaded
        uv.fs_stat(vim.fs.joinpath(vim.uv.cwd(), 'tests', 'fixture')) == nil
    then
        vim.system({ 'make', 'fixture' }, { text = true }, function(out)
            if out.code ~= 0 then
                print(out.stderr)
                return
            end
        end):wait()
        vim.api.nvim_create_autocmd('VimLeavePre', {
            pattern = '*',
            group = vim.api.nvim_create_augroup(
                'clean_testfixture_on_close',
                { clear = true }
            ),
            command = '!make clean',
            once = true,
        })
    end
    vim.cmd('PlenaryBustedDir tests')
end, { desc = 'run [t]ests' })

vim.keymap.set(
    'n',
    '<localleader>mf',
    '!make fixture',
    { desc = '[m]ake [f]ixture' }
)
vim.keymap.set(
    'n',
    '<localleader>mc',
    '!make clean',
    { desc = '[m]ake [c]lean' }
)
vim.keymap.set(
    'n',
    '<localleader>mt',
    '!make test',
    { desc = '[m]ake [t]est' }
)
