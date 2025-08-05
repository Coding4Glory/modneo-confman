---@class ConfmanConfItemFactory
return {
    new = function(settings)
        ---@class ConfmanConfItem
        ---@field category string the plugin category
        ---@field name string the name of the plugin config file
        ---@field settings TinyConfmanSettings
        local M = {}
        M.settings = settings

        M.init = function(category, name)
            M.category = category
            M.name = name
            return M
        end
    end
}

