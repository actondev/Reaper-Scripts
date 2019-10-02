package.path = reaper.GetResourcePath() .. package.config:sub(1, 1) .. '?.lua;' .. package.path
require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.colors'
require 'Scripts.ActonDev.deps.drawing'
debug_mode = 1

label = "ActonDev: Midi Circular Graph"

--[[
boolean retval, boolean selected, boolean muted, number startppqpos, number endppqpos, number chan, number pitch, number vel = reaper.MIDI_GetNote(MediaItem_Take take, integer noteidx)
Get MIDI note properties.

integer reaper.FNG_CountMidiNotes(RprMidiTake midiTake)
[FNG] Count of how many MIDI notes are in the MIDI take

RprMidiNote reaper.FNG_GetMidiNote(RprMidiTake midiTake, integer index)
[FNG] Get a MIDI note from a MIDI take at specified index

gfx.triangle(x1,y1,x2,y2,x3,y3[x4,y4...] )

class RprMidiNote https://github.com/reaper-oss/sws/blob/400c3c13949805afc37b87627a0c8664f436508f/Fingers/RprMidiTake.h#L39


https://www.extremraym.com/cloud/reascript-doc/#FNG_GetMidiNote
--]]
local gui = {}


-- todo
-- function: draw circular piano notes
-- function: draw midi notes
-- support pitch bend?

function rgbToString(rgb)
    local text = "rgb(" .. rgb[1] .. "," .. rgb[2] .. "," .. rgb[3] .. ")"
    return text
end

function unpackRgb(rgb)
    return rgb[1], rgb[2], rgb[3]
end

function pianoRoll(cx, cy, r1, r2)
    local A = 440;
    local white = {1,1,1}
    local black = {0,0,0}
    local colors = {white, -- A
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
    local key_angle = 2*math.pi / 12
    local angle_width = 0.8 * key_angle
    local angle_width_half = angle_width / 2

    for i,key_color in pairs(colors) do
        i = i - 1
        local angle = i * key_angle - math.pi/2 -- -math.pi/2 to make 0 be at the top (12 o'clock)
        local angle_start = angle - angle_width_half
        local angle_end = angle + angle_width_half
        local x = cx + r1*math.cos(angle)
        local y = cy + r1*math.sin(angle)
        gfx.set(unpackRgb(key_color))
        gfx.circle(x, y, r2-r1, true)
    end
end

function drawDot()
    gfx.set(table.unpack(gui.textColor));
    gfx.circle(100, 100, 10)
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


function draw()
    checkThemeChange()-- from colors.lua
    gfx.set(table.unpack(gui.textColor))
    if reaper.GetCursorContext2(true) == 0 then
        context = "tracks"
    else
        context = "items"
    end
    if reaper.CountSelectedMediaItems(0) == 0 then
        context = "tracks"
    end
    
    gfx.x = 0
    gfx.y = 10
    
    gfx.setfont(1, gui.font, gui.fontSize)
    drawString("context ")
    gfx.setfont(1, gui.font, gui.fontSize, string.byte('b'))
    drawString(context)
    gfx.setfont(1, gui.font, gui.fontSize)
    
    -- drawDot()
    pianoRoll(gfx.w/2,gfx.h/2, 40, 48)

end

function mainloop()
    draw()
    gfx.update()
    local c = gfx.getchar()
    -- it's -1 when closed, and 27 at ESC
    if c >= 0 and c ~= 27 and not exit then
        reaper.defer(mainloop)
    end
end
init()
mainloop()
