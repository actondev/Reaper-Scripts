local module = {}

function module.setPosition(t)
    reaper.SetEditCurPos( t, false, false )
end

function module.getPosition(t)
    return reaper.GetCursorPosition()
end

return module