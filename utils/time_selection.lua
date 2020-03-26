local module = {}

local Common = require('utils.common')

function module.setToSelectedItems()
    -- Time selection: Set time selection to items
    Common.cmd(40290)
end

function module.remove()
    -- Time selection: Remove time selection
    Common.cmd(40635)
end

return module