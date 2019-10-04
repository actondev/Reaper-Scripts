package.path = reaper.GetResourcePath() .. package.config:sub(1, 1) .. '?.lua;' .. package.path
require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.colors'
require 'Scripts.ActonDev.deps.drawing'
debug_mode = 0

label = "ActonDev: Midi Circular Graph"

local cursor_now = 0

--[[
TODOs:
- [x] show as "moons" the drawn notes depending on playhead
- [x] see the problem with the bassline in nin - hurt
--]]
-- these are changes later on. read either from projectExtState, or setting C as the key
local keyFreq = 440
local keyName = "A"

local gui = {}

function dump(o)
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

-- taken from http://www.lua.org/pil/5.1.html
function unpack(t, i)
    -- i = i or 1
    -- if t[i] ~= nil then
    --     return t[i], unpack(t, i + 1)
    -- end
    return table.unpack(t)
end

function midi2f(note)
    return 2 ^ ((note - 69) / 12) * 440
end

function log2(x)
    return math.log(x) / math.log(2)
end

function f2angle(root, f)
    return 2 * math.pi * log2(f / root)
end

function rad2deg(rad)
    return (rad * 180) / math.pi
end

-- As suggested in https://github.com/ReaTeam/ReaScripts/blob/master/Various/Lokasenna_Radial%20Menu.lua#L6886
function arcArea(cx, cy, r1, r2, angle1, angle2)
    for r = r1, r2, 0.5 do
        gfx.arc(cx, cy, r, angle1, angle2, 1)-- last paremeter is antialias
    end
end

function getActiveTake()
    local item = reaper.GetSelectedMediaItem(0, 0)
    if item == nil then
        return nil
    end
    return reaper.GetActiveTake(item)
end

function ms2s(ms)
    return ms / 1000
end

function noteLunarInfo(cursorPos, itemStart, itemEnd, noteStart, noteEnd)
    if cursorPos > noteEnd then
        -- return "past-item"
        return {["fill"] = 0, ["waxing"] = true, ["past"] = true}
    elseif cursorPos < noteStart then
        return {["fill"] = (cursorPos-itemStart)/(noteStart - itemStart), ["waxing"] = true}
    else
        local playedFactor = (cursorPos - noteStart) / (noteEnd - noteStart)
        return {["fill"] = 1-playedFactor, ["waxing"] = false}
    end
end

-- either edit cursor or play, depending on playback status
function getCurrentPosition()
    -- return reaper.GetPlayPosition()
    -- return reaper.GetCursorPosition()
    return cursor_now
end

function selectedMidiFrequencies()
    local item = reaper.GetSelectedMediaItem(0, 0)
    if item == nil then
        return {}
    end
    local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local itemEnd = itemStart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    -- fdebug("item end " .. itemEnd)
    cursorPos = getCurrentPosition()-- it's in seconds
    local take = reaper.GetActiveTake(item)
    local _, midiNotesCnt, midiCcCnt, _ = reaper.MIDI_CountEvts(take)
    local midiTake = reaper.FNG_AllocMidiTake(take)
    local freqs = {}
    for i = 0, midiNotesCnt - 1 do
        local _, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
        local noteStartQn = reaper.MIDI_GetProjQNFromPPQPos(take, startppqpos)
        local noteStart = reaper.TimeMap2_QNToTime(0, noteStartQn)
        local noteEndQn = reaper.MIDI_GetProjQNFromPPQPos(take, endppqpos)
        local noteEnd = reaper.TimeMap2_QNToTime(0, noteEndQn)

        if (muted == false)
            -- and cursor_now < noteEnd -- hide past notes?
            and ((noteStart >= itemStart and noteStart < itemEnd) or (noteEnd > itemStart and noteEnd <itemEnd)) then
            noteStart = math.max(itemStart, noteStart)
            noteEnd = math.min(itemEnd, noteEnd)
            -- fdebug("pitch " .. pitch .. " noteStart " .. noteStart .. " noteEnd " .. noteEnd .. " itemStart " .. itemStart .. " itemEnd " .. itemEnd)
            local noteLunarInfo = noteLunarInfo(cursorPos, itemStart, itemEnd, noteStart, noteEnd)
            local f = midi2f(pitch)
            table.insert(freqs, {
                ["f"] = f,
                ["lunar"] = noteLunarInfo
            })
        end
    end

    -- sorting: waxing first, and minimum lit first. warning should be last to draw-replace
    table.sort(freqs,
        function(a,b)
            if a.lunar.waxing == b.lunar.waxing then
                return a.lunar.fill < b.lunar.fill
            end
            return a.lunar.waxing == true and b.lunar.waxing == false
        end)

    -- fdebug("freqs")
    -- fdebug(dump(freqs))
    return freqs
end

-- reference: https://gist.github.com/actonDev/144d156bd3424c223324c8c754ce1eeb
function drawMoon(cx, cy, r, isWaxing, litFactor, points)
    -- fdebug("draw moon lit " .. litFactor .. " wax " .. tostring(isWaxing) .. " cx " .. cx .. " cy " .. cy)
    local shadow = {0, 0, 0}
    local lit = {1, 1, 1}
    local litWaxing = {0.5, 0.5, 0.5}
    local litWarning = {0.7, 0, 0}

    if isWaxing then r = r-1 end -- warning: playing moons bigger (hiding the below artifact)
    
    -- drawing the shadow
    gfx.set(table.unpack(shadow))
    gfx.circle(cx, cy, r, true)

    r = r+1

    if litFactor < 0.001 then
        return
    end

    if isWaxing then
        gfx.set(table.unpack(litWaxing))
    else
        gfx.set(table.unpack(litWarning))
    end
    
    -- drawing the lit part
    dtheta = math.pi / (points - 1)
    
    local angleTop = -math.pi / 2
    local dir = 1
    if isWaxing == false then
        dir = -1
    end
    
    local vertices = {}
    local verticesIn = {}
    local verticesOut = {}
    -- the inside arc
    rin = r * (1 - 2 * litFactor);
    for i = 0, points - 1 do
        -- for i=points-1,0,-1 do
        local theta = angleTop + i * dtheta * dir
        local x = cx + rin * math.cos(theta)
        local y = cy + r * math.sin(theta)
        table.insert(vertices, x)
        table.insert(vertices, y)

        table.insert(verticesIn, x)
        table.insert(verticesIn, y)
        
        gfx.x = x
        gfx.y = y
        gfx.setpixel(0, 1, 0)
    end
    
    -- the outside arc
    for i = 0, points - 1 do
        -- for i=points-1,0,-1 do
        local theta = angleTop + i * dtheta * dir
        local x = cx + r * math.cos(theta)
        local y = cy + r * math.sin(theta)
        table.insert(vertices, x)
        table.insert(vertices, y)

        table.insert(verticesOut, x)
        table.insert(verticesOut, y)
        
        gfx.x = x
        gfx.y = y
        gfx.setpixel(1, 0, 0)
    end

    for i=1,2*points-2,2 do
        gfx.triangle(
            verticesIn[i], -- 2nd point x,y
            verticesIn[i+1],
            verticesIn[i+2], -- 3d point x,y
            verticesIn[i+3],
            verticesOut[i], -- 2nd point x,y
            verticesOut[i+1],
            verticesOut[i+2], -- 3d point x,y
            verticesOut[i+3]
            ,true
        )
    end
end

function drawSelectedMidiFrequencies(opts)
    local r = opts.r
    local root = opts.root
    local cx = opts.cx
    local cy = opts.cy
    local freqs = selectedMidiFrequencies()
    for i, freq in pairs(freqs) do
        local f = freq.f
        local pos = freq.pos
        local angle = f2angle(root, f)
        angle = angle - math.pi / 2 -- 0 at 12 o'clock
        local x = cx + r * math.cos(angle)
        local y = cy + r * math.sin(angle)
        gfx.set(1, 1, 1)
        drawMoon(x, y, 20, freq.lunar.waxing, freq.lunar.fill, 36)
        gfx.set(1, 0, 0)
        gfx.x = x
        gfx.y = y
    -- drawString(freq.info)
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
        gfx.set(table.unpack(key_color))
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
    return {["root"] = keyFreq, ["r"] = 90, ["cx"] = gfx.w / 2, ["cy"] = gfx.h / 2}
end

function draw()
    fdebug("drawing")
    checkThemeChange()-- from colors.lua
    gfx.set(table.unpack(gui.textColor))
    
    gfx.x = 0
    gfx.y = 10
    
    gfx.setfont(1, gui.font, gui.fontSize)
    drawString("Press (k) to select key | key: " .. keyName)
    
    pianoRoll(gfx.w / 2, gfx.h / 2, 40, 50)
    drawSelectedMidiFrequencies(getOpts())
end

local cache_take = nil
function shouldRedrawForTake()
    local take = getActiveTake()
    local shouldRedraw = cache_take ~= take
    cache_take = take
    
    return shouldRedraw
end; shouldRedrawForTake()-- initializing the cache

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
end; shouldRedrawForMidiHash()-- initializing the cache

local cache_edit_pos = nil
function shouldRedrawForEditCursor()
    local pos = reaper.GetCursorPosition()-- it's in seconds
    local shouldRedraw = cache_edit_pos ~= pos
    cache_edit_pos = pos
    cursor_now = pos
    
    return shouldRedraw
end; shouldRedrawForEditCursor()

local cache_play_pos = 0
function shouldRedrawForPlayPosition()
    local pos = reaper.GetPlayPosition()
    local shouldRedraw = math.abs(cache_play_pos - pos) > 0.01
    if shouldRedraw then
        cache_play_pos = pos
        cursor_now = pos
    end

    
    return shouldRedraw
end; shouldRedrawForPlayPosition()

local cache_winsize = {}
function shouldRedrawForResize()
    local shouldRedraw = table.concat(cache_winsize) ~= table.concat({gfx.w, gfx.h})
    cache_winsize = {gfx.w, gfx.h}
    
    return shouldRedraw
end
shouldRedrawForResize()-- initializing the cache

function shouldRedraw()
    return shouldRedrawForTake()
        or shouldRedrawForResize()
        or shouldRedrawForMidiHash()
        or shouldRedrawForEditCursor()
        or shouldRedrawForPlayPosition()
end

function indexOf(coll, search)
    for i, val in ipairs(coll) do
        if val == search then
            return i
        end
    end
    return nil
end

local noteNames = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
function getKeyFreqFromUserMenu()
    -- creating menu string from noteNames table
    local menuStr = table.concat(noteNames, "|")
    local sel = gfx.showmenu(menuStr)
    if sel > 0 then
        local noteName = noteNames[sel]
        setExtState("midi_graph_key", noteName)
        keyName = noteName
        -- i will be from 1 to 11, 1 meaning C. middle C is 60
        return midi2f(sel + 59)
    end
    return nil
end

function getKeyFreqFromProject()
    local val = getExtState("midi_graph_key")
    if val == "" then
        val = "C"
    end
    keyName = val
    noteIndex = indexOf(noteNames, val)
    -- i will be from 1 to 11, 1 meaning C. middle C is 60
    local f = midi2f(noteIndex + 59)
    return f
end

local redraw = true
function mainloop()
    local c = gfx.getchar()
    local forceRedraw = false
    gfx.update()
    
    if c == 107 then -- k
        local f = getKeyFreqFromUserMenu()
        if f ~= nil then
            keyFreq = f
            forceRedraw = true
            fdebug("Got f " .. f)
        else
            fdebug("Nill f")
        end
    end
    
    if forceRedraw or shouldRedraw() == true then
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
