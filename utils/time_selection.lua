local module = {}

local Common = require('utils.common')
local Log = require('utils.log')

function module.setToSelectedItems()
    -- Time selection: Set time selection to items
    Common.cmd(40290)
end

function module.remove()
    -- Time selection: Remove time selection
    Common.cmd(40635)
end

-- returns start,end
function module.get()
    -- start, end = reaper.GetSet_LoopTimeRange( isSet, isLoop, start, end, allowautoseek )
    return reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
end

function module.set(tstart, tend)
    -- start, end = reaper.GetSet_LoopTimeRange( isSet, isLoop, start, end, allowautoseek )
    reaper.GetSet_LoopTimeRange( true, false, tstart, tend, false )
    local gotStart,gotEnd = module.get()
    -- Common.updateArrange()
end

return module