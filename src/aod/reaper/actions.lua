local Log = require("utils.log")

local module = {}

module.SECTION = {
    -- Main=0, Main (alt recording)=100, MIDI Editor=32060, MIDI Event List Editor=32061, MIDI Inline Editor=32062, Media Explorer=32063
    MAIN = 0,
    MAIN_ALT_RECORDING = 100,
    MIDI_EDITOR = 32060,
    MIDI_EVENT_LIST_EDITOR = 32061,
    MIDI_INLINE_EDITOR = 32062,
    MEDIA_EXPLORER = 32063
}

local cache = {}

function module.getActions(section)
    if cache[section] then
        return cache[section]
    end
    local actions = {}

    local i = 0
    local commandId = 1
    while commandId > 0 do
        commandId, name = reaper.CF_EnumerateActions(section, i, "")
        if commandId > 0 then
            -- local commandText = reaper.CF_GetCommandText(section, i)
            -- Log.debug("#" .. tostring(i) .. " : " .. name .. " - " .. commandId)
            actions[#actions + 1] = {name = name, id = commandId}
        end
        i = i + 1
    end
    cache[section] = actions
    return actions
end



return module
