---@class ConfmanConfItemFactory
return {
    new = function()
        ---@class ConfmanConfItem
        ---@field category string the plugin category
        ---@field name string the name of the plugin config file
        local M = {}

        M.init = function(category, name)
            M.category = category
            M.name = name
            return M
        end
    end
}

