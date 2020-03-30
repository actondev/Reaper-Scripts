local Log = require('utils.log')

local module = {}

module.SECTION = {
        -- Main=0, Main (alt recording)=100, MIDI Editor=32060, MIDI Event List Editor=32061, MIDI Inline Editor=32062, Media Explorer=32063
        MAIN = 0,
        MAIN_ALT_RECORDING = 100,
        MIDI_EDITOR = 32060,
        MIDI_EVENT_LIST_EDITOR = 32061,
        MIDI_INLINE_EDITOR = 32062,
        MEDIA_EXPLORER = 32063,
}
function module.getActions(section, limit)
    if limit == nil then
        limit = 10
    end
    local tResult = {}
    
    local i = 0
    local commandId = 1
    while commandId > 0 do
        commandId, name = reaper.CF_EnumerateActions(section, i, "")
        if commandId > 0 then
            -- local commandText = reaper.CF_GetCommandText(section, i)
            -- Log.debug("#" .. tostring(i) .. " : " .. name .. " - " .. commandId)
            tResult[#tResult + 1] = {name = name, id = commandId}
        end
        i = i + 1
        
        if limit ~= false and i == limit then
            break
        end
    end
    return tResult
end

local function getSectionName(section)
    for k, v in pairs(module.SECTION) do
        if section == v then return k end
    end
    return nil
end

local commandCache = {}

-- @param limit: should be false to not limit, if nil a default of 10 is applied
function module.search(section, query, limit)
    if limit == nil then
        limit = 10
    end
    local results = {}
    local sectionName = getSectionName(section)
    if commandCache[sectionName] == nil then
        -- Log.debug("caching " .. sectionName)
        commandCache[sectionName] = module.getActions(section, false)
        -- Log.debug("cached " .. #commandCache[sectionName])
    end
    
    for _, action in ipairs(commandCache[sectionName]) do
        actionLowercase = string.lower(action.name)
        local match = true
        -- all words in the query string must match the action name
        for token in string.gmatch(query, "[^%s]+") do
            if not string.find(actionLowercase, token:lower(), 1, true) then
                match = false
                break
            end
        end

        if match then
            results[#results+1] = action
        end
        if limit and #results == limit then
            break
        end
    end

    -- Log.debug("result count " .. tostring(#results))
    return results
end

return module
