package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local Theme = require("utils.theme")
local Gui = require("utils.gui")
local Item = require("aod.reaper.item")
local Track = require("aod.reaper.track")
local Common = require("aod.reaper.common")

local label = "actondev/Color Swatch"
local imageSrc = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "resources/swatch.png"

local gui = {}

imageMarginTop = 30
margin = 5
textTop = 14
textSpacing = 3
textTab = 170
hasClicked = false
exit = false

r = 0
g = 0
b = 0

contextTracks = "TRACK(S)"
contextItems = "ITEM(S)"

local themeFile = Theme.file()
local themeContent = Theme.content(themeFile)

function updateColors()
	gfx.clear = Theme.colorSingle(themeContent, "col_main_bg2")
	gui.textColor = {Theme.colorRGB(themeContent, "col_main_text2")}
end

function init()
	-- Add stuff to "gui" table
	gui.settings = {} -- Add "settings" table to "gui" table
	gui.settings.font_size = 14 -- font size
	gui.settings.docker_id = 0 -- try 0, 1, 257, 513, 1027 etc.
	gui.font = "Verdana"
	gui.fontSize = 15

	updateColors()

	---------------------------
	-- Initialize gfx window --
	---------------------------

	image = 1
	image = gfx.loadimg(image, imageSrc)

	imageW, imageH = gfx.getimgdim(image)
	gfx.init(label, imageW + 2 * margin, imageH + imageMarginTop + margin)

	Common.moveWindowToMouse()

	-- gfx.clear = 3355443  -- matches with "FUSION: Pro&Clean Theme :: BETA 01" http://forum.cockos.com/showthread.php?t=155329
	-- (Double click in ReaScript IDE to open the link)
	gfx.setfont(1, gui.font, gui.fontSize)
end

--------------
-- Mainloop --
--------------

function initDraw()
	-- checkThemeChange()
	gfx.set(table.unpack(gui.textColor))
	if reaper.GetCursorContext2(true) == 0 then
		context = contextTracks
	else
		context = contextItems
	end
	if reaper.CountSelectedMediaItems(0) == 0 then
		context = contextTracks
	end

	gfx.x = margin
	gfx.y = textTop

	gfx.setfont(1, gui.font, gui.fontSize)
	Gui.drawString("context ")
	gfx.setfont(1, gui.font, gui.fontSize, string.byte("b"))
	Gui.drawString(context)
	gfx.setfont(1, gui.font, gui.fontSize)
	gfx.y = textTop
	gfx.x = imageW * 0.2
	gfx.y = textTop
	gfx.setfont(1, gui.font, gui.fontSize * 0.9, string.byte("i"))
	gfx.x = gfx.w - margin
	Gui.drawString(
		"Left Click and drag (setting color on mouse release). To reset to default color, release on this upper area",
		"right"
	)

	-- seperator
	gfx.set(table.unpack(gui.textColor))
	gfx.a = 0.2
	gfx.line(0, imageMarginTop - 5, gfx.w, imageMarginTop - 5)
	-- image swatch
	gfx.x = margin
	gfx.y = imageMarginTop
	gfx.a = 1
	gfx.blit(image, 1, 0)
end

function clickDraw()
	gfx.set(table.unpack(gui.textColor))
	gfx.a = 0.2
	gfx.line(0, imageMarginTop - 5, gfx.w, imageMarginTop - 5)
	gfx.x = margin
	gfx.y = imageMarginTop
	gfx.a = 1
	gfx.blit(image, 1, 0)

	local shouldResetColor = false
	local r, g, b = 0, 0, 0

	gfx.x = margin
	gfx.y = margin
	if (gfx.mouse_y > imageMarginTop) then
		-- colorize(true, r, g, b)
		gfx.x = gfx.mouse_x
		gfx.y = gfx.mouse_y
		r, g, b = gfx.getpixel()
		gfx.set(r, g, b)
		r = math.floor(r * 255)
		g = math.floor(g * 255)
		b = math.floor(b * 255)
		gfx.y = margin
		gfx.x = margin

		gfx.rectto(gfx.x + 20, gfx.y + 20)
		gfx.set(table.unpack(gui.textColor))
		gfx.setfont(1, gui.font, gui.fontSize, string.byte("b"))
		gfx.y = textTop
		gfx.x = gfx.x + textSpacing
		Gui.drawString(context)
		gfx.setfont(1, gui.font, gui.fontSize)
		Gui.drawString(": set to RGB (" .. r .. "," .. g .. "," .. b .. ")")
	else
		-- colorize(false)
		gfx.y = textTop
		gfx.x = margin + 20 + textSpacing
		shouldResetColor = true
		-- gfx.set(gui.textColor)
		gfx.setfont(1, gui.font, gui.fontSize, string.byte("b"))
		Gui.drawString(context)
		gfx.setfont(1, gui.font, gui.fontSize)
		Gui.drawString(": reset to default color")
	end

	local ctx = Common.getEditContext()
	if ctx == Common.EDIT_CONTEXT.ITEM then
		local items = Item.selected()
		for _, item in pairs(items) do
			if shouldResetColor then
				Item.unpaint(item)
			else
				Item.paint(item, r, g, b)
			end
		end
	elseif ctx == Common.EDIT_CONTEXT.TRAK then
		local tracks = Track.selected()
		for _, track in pairs(tracks) do
			if shouldResetColor then
				Track.unpaint(track)
			else
				Track.paint(track, r, g, b)
			end
		end
	end
	-- need to call updateArrange to reflect the new colors
	Common.updateArrange()
end

function release()
	gfx.x = gfx.mouse_x
	gfx.y = gfx.mouse_y
	Gui.drawString("Goodbye")
	exit = true
end

function mainloop()
	if gfx.mouse_cap == 0 then
		if not hasClicked then
			initDraw()
		else
			release()
		end
	elseif gfx.mouse_cap == 1 then
		-- left click
		hasClicked = true
		clickDraw()
	end
	gfx.update()
	local c = gfx.getchar()
	-- it's -1 when closed, and 27 at ESC
	if c >= 0 and c ~= 27 and not exit then
		reaper.defer(mainloop)
	end
end

reaper.atexit(
	function()
		reaper.Undo_EndBlock(label, -1)
	end
)

reaper.Undo_BeginBlock()
init()
mainloop()
