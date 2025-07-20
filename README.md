# tiny.nvim config manager

aka tiny-confman.nvim

tiny-confman.nvim is a neovim plugin to enable and disable plugins for users
maintaining a modular config approach.

## Setup 🚀 and Configuration ⚙️

```lua
-- Lazy
{
    'Coding4Glory/tiny-confman.nvim',
    -- Add your settings here, pass empty table for default settings (required)
    opts = {
        -- the folder where category folders are placed,
        -- the default value leads to ~/.config/nvim/lua/plugins
        plugin_dir = 'plugins',
        -- the folder where symlinks to enabled config files will be loaded
        -- will be expected inside the plugin_dir
        link_dir = 'enabled',
    },
},
```

## Usage 🛠

### Plugin configs 🗂

Organize your plugins into categories by putting them into subfolders as shown.
This figure this matches the default config with categories _basics_, _container_
and _ide_:

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
                                                    *:TinyEnPlug* *TinyEnPlug*
:TinyEnPlug {category/module}          enables a module.

                                                  *:TinyDisPlug* *TinyDisPlug*
:TinyDisPlug {category/module}         disables a module.

                                                    *:TinyLsPlug* *TinyLsPlug*
:TinyLsPlug                            list all categories and modules
```

## Help ❔

Run `:help tiny-confman` for more details.

