package.path = reaper.GetResourcePath() .. package.config:sub(1, 1) .. '?.lua;' .. package.path
require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.colors'
require 'Scripts.ActonDev.deps.drawing'
debug_mode = 0

label = "ActonDev: Midi Circular Graph"

-- these are changes later on. read either from projectExtState, or setting C as the key
local keyFreq = 440
local keyName ="A"

local gui = {}

local white = {1, 1, 1}
local black = {0, 0, 0}
-- starting from A/La/440Hz
local keyColors = {
    white, -- A
    black, -- A#
    white, -- B
    white, -- C
    black, -- C#
    white, -- D
    black, -- D#
    white, -- E
    white, -- F
    black, -- F#
    white, -- G
    black -- G#
}

function rgb2string(rgb)
    local text = "rgb(" .. rgb[1] .. "," .. rgb[2] .. "," .. rgb[3] .. ")"
    return text
end

function unpackRgb(rgb)
    return rgb[1], rgb[2], rgb[3]
end

function midi2f(note)
    return 2^((note-69)/12) * 440
end

function log2(x)
    return math.log(x) / math.log(2)
end

function f2angle(root, f)
    return 2 * math.pi * log2(f/root)
end

function rad2deg(rad)
    return (rad * 180)/math.pi
end

-- As suggested in https://github.com/ReaTeam/ReaScripts/blob/master/Various/Lokasenna_Radial%20Menu.lua#L6886
function arcArea(cx, cy, r1, r2, angle1, angle2)
    for r = r1, r2, 0.5 do
        gfx.arc(cx, cy, r, angle1, angle2, 1) -- last paremeter is antialias
    end
end

function getActiveTake()
    local item = reaper.GetSelectedMediaItem(0, 0)
    if item == nil then
        return nil
    end
    return reaper.GetActiveTake(item)
end

function selectedMidiFrequencies()
    local item = reaper.GetSelectedMediaItem(0, 0)
    if item == nil then
        return {}
    end
    local take = reaper.GetActiveTake(item)
    local _, midiNotesCnt, midiCcCnt, _ = reaper.MIDI_CountEvts(take)
    local midiTake =  reaper.FNG_AllocMidiTake( take )
    local freqs = {}
    for i = 0,midiNotesCnt-1 do
        local note = reaper.FNG_GetMidiNote( midiTake, i )
        local pitch = reaper.FNG_GetMidiNoteIntProperty(note, "PITCH")
        local f = midi2f(pitch)
        table.insert(freqs, f)
    end
    return freqs
end

function drawSelectedMidiFrequencies(opts)
    local r = opts.r
    local root = opts.root
    local cx = opts.cx
    local cy = opts.cy
    local freqs = selectedMidiFrequencies()
    gfx.set(1,1,1)
    for i,f in pairs(freqs) do
        local angle = f2angle(root, f)
        angle = angle - math.pi/2 -- 0 at 12 o'clock
        local x = cx + r * math.cos(angle)
        local y = cy + r * math.sin(angle)
        gfx.circle(x,y,10, true)
        -- fdebug("midi note " .. i .. " f " .. f .. " deg " .. rad2deg(angle))
    end
end

-- note: it access keyFreq, keyColors.. not entirely isolated :)
-- underscore in some places cause I copied some clojure code (slash to underscore..)
function pianoRoll(cx, cy, r1, r2)
    local angle_width = 0.8 * 2 * math.pi / 12
    local angle_width_half = angle_width / 2
    
    for i, key_color in pairs(keyColors) do
        i = i - 1 -- 0 will be A
        local pianoRollNote = 69 + i -- 69 is A4, 440Hz
        local f = midi2f(pianoRollNote)
        local angle = f2angle(keyFreq, f)
        local angle_start = angle - angle_width_half
        local angle_end = angle + angle_width_half
        gfx.set(unpackRgb(key_color))
        arcArea(cx, cy, r1, r2, angle_start, angle_end)
    end
end

-- this is called from the colors.lua lib
function scriptColors()
    gfx.clear = themeColor("col_main_bg2")
    gui.textColor = {themeColor("col_main_text2", true)}
end

function init()
    -- Add stuff to "gui" table
    gui.settings = {}-- Add "settings" table to "gui" table
    gui.settings.font_size = 14 -- font size
    gui.settings.docker_id = 0 -- try 0, 1, 257, 513, 1027 etc.
    gui.font = "Verdana"
    gui.fontSize = 15
    scriptColors()
    
    ---------------------------
    -- Initialize gfx window --
    ---------------------------
    gfx.init(label, 500, 500)
    
    reaperCMD("_BR_MOVE_WINDOW_TO_MOUSE_H_M_V_B")
    
    gfx.setfont(1, gui.font, gui.fontSize)
end

function getOpts()
    -- r is for the place to start drawing the notes
    return {["root"] = keyFreq, ["r"] = 80, ["cx"] = gfx.w/2, ["cy"] = gfx.h/2}
end

function draw()
    fdebug("drawing")
    checkThemeChange()-- from colors.lua
    gfx.set(table.unpack(gui.textColor))
    
    gfx.x = 0
    gfx.y = 10
    
    gfx.setfont(1, gui.font, gui.fontSize)
    drawString("Press (k) to select key | key: " .. keyName )
    
    pianoRoll(gfx.w / 2, gfx.h / 2, 40, 50)
    drawSelectedMidiFrequencies(getOpts())
end

local cache_take = nil
function shouldRedrawForTake()
    local take = getActiveTake()
    local shouldRedraw = cache_take ~= take
    cache_take = take

    return shouldRedraw
end
shouldRedrawForTake() -- initializing the cache

local cache_hash = nil
function shouldRedrawForMidiHash()
    local take = getActiveTake()
    if take == nil then 
        return false
    end
    local _, hash = reaper.MIDI_GetHash(take, false, "")
    local shouldRedraw = cache_hash ~= hash
    cache_hash = hash

    return shouldRedraw
end
shouldRedrawForMidiHash() -- initializing the cache

local cache_winsize = {}
function shouldRedrawForResize()
    local shouldRedraw = table.concat(cache_winsize) ~= table.concat({gfx.w, gfx.h})
    cache_winsize = {gfx.w, gfx.h}

    return shouldRedraw
end
shouldRedrawForResize() -- initializing the cache

function shouldRedraw()
    return shouldRedrawForTake()
        or shouldRedrawForResize()
        or shouldRedrawForMidiHash()
end

function indexOf(coll, search)
    for i,val in ipairs(coll) do
        if val == search then
            return i
        end
    end
    return nil
end

local noteNames = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
function getKeyFreqFromUserMenu()
    -- creating menu string from noteNames table
    local menuStr = table.concat(noteNames,"|")
    local sel = gfx.showmenu(menuStr)
    if sel > 0 then
        local noteName = noteNames[sel]
        setExtState("midi_graph_key", noteName)
        keyName = noteName
        -- i will be from 1 to 11, 1 meaning C. middle C is 60
        return midi2f(sel+59)
    end
    return nil
end

function getKeyFreqFromProject()
    local val = getExtState("midi_graph_key")
    val = val or "C"
    keyName = val
    noteIndex = indexOf(noteNames, val)
    -- i will be from 1 to 11, 1 meaning C. middle C is 60
    local f = midi2f(noteIndex+59)
    return f
end

local redraw = true
function mainloop()
    local c = gfx.getchar()
    gfx.update()

    if c == 107 then -- k
        local f = getKeyFreqFromUserMenu()
        if f ~= nil then
            keyFreq = f
            fdebug("Got f " .. f)
        else
            fdebug("Nill f")
        end
    end

    if shouldRedraw() == true then
        draw()
    end

    redraw = false
    if c >= 0 and c ~= 27 and not exit then
        reaper.defer(mainloop)
    end
end
init()
keyFreq = getKeyFreqFromProject()
mainloop()
