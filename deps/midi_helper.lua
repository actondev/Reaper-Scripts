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

 -- as seen in https://gist.github.com/tylerneylon/81333721109155b2d244
 local function copy1(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[copy1(k)] = copy1(v) end
    return res
  end

function midiHelper.midiStructureToRelativeTimings(data, t)
    local newFrequencies = {}
    if data == nil then return {} end
    if data.item == nil then return {} end
    local itemStart = data.item.tstart
    local itemEnd = data.item.tend
    for _,event in pairs(data.frequencies) do
        local noteStart = event.tstart
        local noteEnd = event.tend

        -- "cropping" notes to the borders of the item
        noteStart = math.max(itemStart, noteStart)
        noteEnd = math.min(itemEnd, noteEnd)
        if
        (
            (noteStart >= itemStart and noteStart < itemEnd)
            or (noteEnd > itemStart and noteEnd < itemEnd)
        )
        then
            local tend = noteEnd - t
            -- if tend > 0 then -- if not, the event has already ended
                local tstart = noteStart - t
                local f = event.f
                table.insert(newFrequencies, {f = f, tstart = tstart, tend = tend})
            -- end
        end
    end

    local newData = copy1(data)
    -- fdebug("old data " .. dump(data))
    -- fdebug("newData " .. dump(newData))
    newData.item.tstart = itemStart - t
    newData.item.tend = itemEnd - t
    newData.frequencies = newFrequencies
    return newData
end

function midiHelper.midi2f(note)
    return 2 ^ ((note - 69) / 12) * 440
end

local function minimumFrequency(midiStructure)
    local min = 44100
    for _,event in pairs(midiStructure.frequencies) do
        local f = event.f
        min = math.min(min,f)
    end

    return min
end

function midiHelper.getNormalizedKey(key, midiStructure)
    local minF = minimumFrequency(midiStructure)
    local normalizedKey = key

    -- case when the key is far too low
    while normalizedKey <= minF/2 do
        normalizedKey = normalizedKey*2
    end
 
    -- case when the key if far too high
    while normalizedKey > minF do
        normalizedKey = normalizedKey/2
    end

    return normalizedKey
end

return midiHelper;