local module = {}
local TimeSelection = require('utils.time_selection')

local start_time, end_time = 0, 0;
function module.storeArrangeView()
    start_time, end_time = reaper.GetSet_ArrangeView2(0, false, 0, 0, start_time, end_time)
end

function module.restoreArrangeView()
    reaper.GetSet_ArrangeView2(0, true, 0, 0, start_time, end_time)
end

local cursorPosition = 0

function module.storeCursorPosition()
    cursorPosition =  reaper.GetCursorPosition()
end

function module.restoreCursorPosition()
    reaper.SetEditCurPos( cursorPosition, false, false )
end

local time_sel_start, time_sel_end = 0,0
function module.storeTimeSelection()
    time_sel_start,time_sel_end = TimeSelection.get()
end

function module.restoreTimeSelection()
    TimeSelection.set(time_sel_start,time_sel_end)
end

return module