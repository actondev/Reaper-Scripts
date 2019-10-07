local midiHelper = {}

local function makeEventsRelative(data, t)
    local itemStart
    return data
end

local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

function midiHelper.relevantFrequenciesFromMidiStructure(data, t)
    print("hi from midi helper")
    local relevantF = {}
    local itemStart = data.item.tstart
    local itemEnd = data.item.tend
    for _,event in pairs(data.frequencies) do
        local tend = itemStart + event.tend - t
        if tend > 0 then -- if not, the event has already ended
            local tstart = itemStart + event.tstart - t
            local f = event.f
            table.insert(relevantF, {["f"] = f, ["tstart"] = tstart, ["tend"] = tend})
        end
    end
    return relevantF
end

return midiHelper;