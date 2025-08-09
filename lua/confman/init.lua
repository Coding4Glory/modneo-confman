---@class TinyConfmanLoader
---@field setup function loads the module
return {
    ---@param opts TinyConfmanSettings custom settings
    setup = function(opts)
        local settings = require('confman.config').init(opts)
        local module = require('confman.core').setup(settings)
        require('confman.commands').setup(module)
    end,
}
