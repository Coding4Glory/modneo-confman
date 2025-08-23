# modneo config manager

aka modneo-confman

modneo-confman is a neovim plugin to enable and disable plugins for users maintaining a modular config approach.

## Features ✨

- Interactive UI
- Auto completion for plugin commands
- unit tested

## Setup 🚀 and Configuration ⚙️

> ⚠ ⚡ This plugin performs changes on your filesystem! read the following section carefully before continuing!


Setup with lazy

```lua
{
    'Coding4Glory/tiny-confman.nvim',
    -- Add your settings here, pass empty table for default settings (required)
    opts = {
        ---The directory where the plugin categories are located, defaults to
        ---lua/plugins. The path is expected to be relative.
        plugin_lib = vim.fs.joinpath('lua', 'plugins'),
        ---The directory where links to enabled plugins shall be stored
        ---if not existing the directory will be created in the plugin_dir.
        ---The same directory has to be set in lazy, will be created within
        ---plugin_dir.
        link_dir = 'enabled',
        ---The directory where the user configuration is stored, defaults to
        ---`~/.config/nvim.` The default value is retrieved via `stdpath` so
        ---setting this value is usually not required and also not recommended
        ---doing so will change the *state* folder for the plugin which in
        ---this case defaults to the config directory by purpose.
        config_root = vim.fn.stdpath('config'),
        ---the suffix part of a file glob pattern without leading asterisk
        ---has to start with a dot (will not be added automatically) except
        ---your system does not use dot's for file suffix separation (is there
        ---any where neovim runs on?).
        ---Might be set to .lua to ignore .vim files or vice versa.
        default_filter = '.[lv][iu][am]',
    },
},
```

## Usage 🛠

At this point the plugin is meant to be used in conjunction with lazy. To make this work the link dir should be the only folder imported by lazy. Following example should give you the details if you're familiar with lazy.

> If not you should learn more about your configuration before continuing 😉

```lua
require("lazy").setup({
    spec = {
        { import = 'plugins/enabled' }
    }
})
```

### Plugin configs 🗂

Organize your plugins into categories by putting them into subfolders as shown. This figure this matches the default config with categories *basics*, *container* and *ide*:

    .config/nvim/lua/plugins
    ├── basics
    ├── container
    └── ide

create also an enabled folder

    .config/nvim/lua/plugins
    ├── ...
    └── enabled

Folders will be seen as categories, further hierarchies are currently not supported.

### Commands ⌨

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
