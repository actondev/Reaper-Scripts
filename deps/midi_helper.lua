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
    if data == nil then return {} end
    if data.item == nil then return {} end
    local itemStart = data.item.tstart
    local itemEnd = data.item.tend
    for _,event in pairs(data.frequencies) do
        local noteStart = event.tstart
        local noteEnd = event.tend
        if t < event.tend
        and (
            (noteStart >= itemStart and noteStart < itemEnd)
            or (noteEnd > itemStart and noteEnd < itemEnd)
        )
        then
            noteStart = math.max(itemStart, noteStart)
            noteEnd = math.min(itemEnd, noteEnd)
            local tend = noteEnd - t
            -- if tend > 0 then -- if not, the event has already ended
                local tstart = noteStart - t
                local f = event.f
                table.insert(relevantF, {f = f, tstart = tstart, tend = tend})
            -- end
        end
    end
    return {
        item = {tstart = itemStart - t, tend = itemEnd - t},
        frequencies = relevantF
    }
end

return midiHelper;