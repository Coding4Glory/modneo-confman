# modneo config manager

aka modneo-confman

modneo-confman is a neovim plugin to enable and disable plugins for users
maintaining a modular config approach.

## Features ✨

- Interactive UI
- Auto completion for plugin commands
- unit tested

## Setup 🚀 and Configuration ⚙️

> ⚠ ⚡ This plugin performs changes on your filesystem! read the following section carefully before continuing!


Setup with lazy

```lua
{
    'Coding4Glory/modneo-confman.nvim',
    -- Add your settings here, pass empty table for default settings (required)
    opts = {
        ---The directory where the plugin categories are located, defaults to
        ---lua/plugins. The path is expected to be relative.
        ---@type string
        plugin_lib = vim.fs.joinpath('lua', 'plugins'),
        ---The strategy to use to distinguish between enabled and disabled
        ---configurations. This setting defines if following options are
        ---considered. Possible options are 'symlink' and 'rename', defaults to
        ---'symlink' on linux and 'rename' on Windows.
        ---Autoload directories like ftplugin will allways use rename strategy
        ---@type Modneo.ConfmanStrategy
        strategy = 'symlink',
        ---The suffix to add to disabled files if the strategy is set to rename
        disabled_suffix = '.off',
        ---This setting is only considered for the *symlink* strategy.
        ---The directory where links to enabled plugins shall be stored.
        ---It needs to be created in the plugin_dir. The same directory has to
        ---be set in lazy.
        ---@type string
        link_dir = 'enabled',
        ---The directory where the user configuration is stored, defaults to
        ---`~/.config/nvim.` The default value is retrieved via `stdpath` so
        ---setting this value is usually not required and also not recommended
        ---doing so will change the *state* folder for the plugin which in
        ---this case defaults to the config directory by purpose.
        ---@type string
        config_root = vim.fn.stdpath('config'),
        ---The suffix part of a file glob pattern without leading asterisk.
        ---It has to start with a dot (will not be added automatically) except
        ---your system does not use dot's for file suffix separation (is there
        ---any where neovim runs on?). Might be set to .lua to ignore .vim
        ---files or vice versa.
        ---@type string
        default_filter = '.[lv][iu][am]',
        ---the sign used to highlight enabled plugins in the dialog window
        ---@type string
        enabled_sign = '*'
    },
},
```

The advantage of symlinks is to keep syntax highlighting and lsp enabled if
your neovim is configured for plugin development.

## Usage 🛠

### Plugin configs 🗂

Organize your plugins into categories by putting them into subfolders as shown.
This figure this matches the default config with categories *basics*,
*container* and *ide*:

    .config/nvim/lua/plugins
    ├── basics
    ├── container
    └── ide

create also an enabled folder if the symlink strategy is used.

    .config/nvim/lua/plugins
    ├── ...
    └── enabled

Folders will be seen as categories, further hierarchies are currently not
supported.

### symlink strategy 🔗

At this point the plugin is meant to be used in conjunction with lazy. To make
this work the link dir should be the only folder imported by lazy. Following
example should give you the details if you're familiar with lazy.

> If not you should learn more about your configuration before continuing 😉

```lua
require("lazy").setup({
    spec = {
        { import = 'plugins/enabled' }
    }
})
```

### rename strategy 🏷

In the rename strategy files will be renamed between .off and not .off. This
way you won't need an enabled folder and the plugin can be used on systems
without symlink support. In that case all category folders must be included in
the lazy configuration.

```lua
require("lazy").setup({
    spec = {
        { import = 'plugins/basics' },
        { import = 'plugins/container' },
        { import = 'plugins/ide' }
    }
})
```

## Commands ⌨

```vimdoc
                                                                  *Confman-UI*
:Confman                               shows the floating UI
                                                               *ConfmanEnable*
:ConfmanEnable {category/module}       enables a config file.

                                                              *ConfmanDisable*
:ConfmanDisable {category/module}      disables a config file.

                                                                 *ConfmanList*
:ConfmanList                           lists all categories with their config
                                       files

                                                                 *ConfmanInfo*
:ConfmanInfo                           lists all enabled plugins (no category
                                       shown).
```

The plugin also supports the `checkhealth` command.

    :checkhealth confman

## Help ❔

Run `:help tiny-confman` for more details.

## Known Issues ⚠

- The enabled directory is not created automatically.
- UI is not automatically refereshed when plugin is enabled via command instead of keybinding

## Contribution 🤜🤛

See [dedicated file](CONTRIB.md)

<!-- this might not be the style you expect from a markdown file, but it works well with pandocvim -->

<!-- vim: set et ts=4 sw=4 tw=78: -->
