local module = {}

local start_time, end_time = 0, 0;
function module.store()
    start_time, end_time = reaper.GetSet_ArrangeView2(0, false, 0, 0, start_time, end_time)
end

function module.restore()
    reaper.GetSet_ArrangeView2(0, true, 0, 0, start_time, end_time)
end

return module