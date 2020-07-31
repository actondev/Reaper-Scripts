local midiHelper = {}

local function makeEventsRelative(data, t)
    local itemStart
    return data
end

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
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

local function drawPriority(e)
    if e.tend < 0 then return 0 -- past
    elseif e.tstart > 0 then return 1 -- future
    else return 2 -- current
    end
end

function midiHelper.midiStructureToRelativeTimings(data, t)
    local newFrequencies = {}
    if data == nil then return {} end
    if data.item == nil then return {} end
    local itemStart = data.item.tstart
    local itemEnd = data.item.tend
    for _, event in pairs(data.frequencies) do
        local noteStart = event.tstart
        local noteEnd = event.tend
        if
        (
        (noteStart >= itemStart and noteStart < itemEnd)-- starts in
            or (noteEnd > itemStart and noteEnd < itemEnd)-- ends in
            or (noteStart < itemStart and noteEnd > itemEnd)-- starts before, ends after
        )
        then
            -- "cropping" notes to the borders of the item
            noteStart = math.max(itemStart, noteStart)
            noteEnd = math.min(itemEnd, noteEnd)

            local tend = noteEnd - t
            local tstart = noteStart - t
            local f = event.f
            local newEvent = {f = f, tstart = tstart, tend = tend}
            table.insert(newFrequencies, newEvent)
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

function midiHelper.orderForCurrentPlayingPriorityold(midiStructure)
    if midiStructure.frequencies == nil then return end
    local startEndProd = function(e)
        if e.tstart < 0 and e.tend < 0 then return math.huge end
        return e.tstart * e.tend
    end
    table.sort(midiStructure.frequencies,
        function(a, b)
            local aProd = startEndProd(a)
            local bProd = startEndProd(b)
            return aProd > bProd
        end)
end

function midiHelper.orderForCurrentPlayingPriority(midiStructure)
    if midiStructure.frequencies == nil then return end
    table.sort(midiStructure.frequencies,
        function(a, b)
            local drawPriorA = drawPriority(a)
            local drawPriorB = drawPriority(b)
            if drawPriorA == drawPriorB then
                return a.tstart > b.tstart
            end
            return drawPriorA < drawPriorB
        end)
end


function midiHelper.midi2f(note)
    return 2 ^ ((note - 69) / 12) * 440
end

local function minimumFrequency(midiStructure)
    local min = nil
    if midiStructure.frequencies == nil then
        return nil
    end
    for _, event in pairs(midiStructure.frequencies) do
        local f = event.f
        if min == nil then min = f end
        min = math.min(min, f)
    end
    
    return min
end

local function maximumFrequency(midiStructure)
    local max = 0
    if midiStructure.frequencies == nil then
        return nil
    end
    for _, event in pairs(midiStructure.frequencies) do
        local f = event.f
        max = math.max(max, f)
    end
    
    return max
end

local function getClosestKeyFrequency(key, f, asc)
    if asc then
        while key > 2*f do
            key = key / 2
        end
        while key < f do
            key = key * 2
        end
    else
        -- desc
        while key <= f/2 do
            -- we are lower
            key = key * 2
        end
        while key > f do
            -- we are higher
            key = key / 2
        end
    end
    return key
end

function midiHelper.getNormalizedKey(key, midiStructure)
    local minF = minimumFrequency(midiStructure)
    if minF == nil then return key end
    local normalizedKey = getClosestKeyFrequency(key, minF, false)
    
    return normalizedKey
end

function midiHelper.getNormalizedKeys(key, midiStructure)
    local minF = minimumFrequency(midiStructure)
    local maxF = maximumFrequency(midiStructure)
    local keyLow = getClosestKeyFrequency(key, minF, false)
    local keyHigh = getClosestKeyFrequency(key, maxF, true)
    
    return {low = keyLow, high = keyHigh}
end

function midiHelper.getKeyMinMax(key, midiStructure)
    local minF = minimumFrequency(midiStructure)
    if minF == nil then return key end
    local normalizedKey = key
    
    -- case when the key is far too low
    while normalizedKey <= minF / 2 do
        normalizedKey = normalizedKey * 2
    end
    
    -- case when the key if far too high
    while normalizedKey > minF do
        normalizedKey = normalizedKey / 2
    end
    
    return normalizedKey
end

return midiHelper;
