local module = {}

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

return module