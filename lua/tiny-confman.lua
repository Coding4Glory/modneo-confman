---@class TinyConfmanLoader
---@field setup function loads the module
return {
    ---@param opts TinyConfmanSettings custom settings
    setup = function(opts)
        local settings = require('tiny-confman.config').setup(opts)
        local module = require('tiny-confman.core').init(settings)
        require('tiny-confman.commands').setup(module)
    end,
}
