package.path = reaper.GetResourcePath().. package.config:sub(1,1) .. '?.lua;' .. package.path
require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.colors'
require 'Scripts.ActonDev.deps.drawing'
debug_mode = 0

label = "ActonDev: Color Swatch"
imageSrc = reaper.GetResourcePath()..'/Scripts/ActonDev/deps/swatch.png';

-- function colorize in actondev.template

local gui = {}

imageMarginTop = 30
margin = 5
textTop = 14
textSpacing = 3
textTab = 170
hasClicked = false
exit = false

r=0
g=0
b=0

contextTracks = "TRACK(S)"
contextItems = "ITEM(S)"

function scriptColors()
	gfx.clear = themeColor("col_main_bg2")
	gui.textColor = {themeColor("col_main_text2", true)}
end

function init()
	-- Add stuff to "gui" table
	gui.settings = {}                 -- Add "settings" table to "gui" table 
	gui.settings.font_size = 14       -- font size
	gui.settings.docker_id = 0        -- try 0, 1, 257, 513, 1027 etc.
	gui.font = "Verdana"
	gui.fontSize = 15
	
	scriptColors()

	fdebug(gui.textColor[1])
	---------------------------
	-- Initialize gfx window --
	---------------------------


	image = 1;
	fdebug(imageSrc)
	image = gfx.loadimg(image,imageSrc);

	-- fdebug(image)
	imageW,imageH = gfx.getimgdim(image)
	gfx.init(label, imageW+2*margin, imageH+imageMarginTop+margin)

	reaperCMD("_BR_MOVE_WINDOW_TO_MOUSE_H_M_V_B")

	-- gfx.clear = 3355443  -- matches with "FUSION: Pro&Clean Theme :: BETA 01" http://forum.cockos.com/showthread.php?t=155329
	-- (Double click in ReaScript IDE to open the link)
	gfx.setfont(1, gui.font, gui.fontSize)
	-- gfx.blit(image,1,0)
end

--------------
-- Mainloop --
--------------

function initDraw()
	checkThemeChange()
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
	drawString("context ")
	gfx.setfont(1, gui.font, gui.fontSize, string.byte('b'))
	drawString(context)
	gfx.setfont(1, gui.font, gui.fontSize)
	gfx.y = textTop
	gfx.x = imageW*0.2
	-- gfx.setfont(1,"Arial", gui.font_size*0.8)
	gfx.y = textTop
	gfx.setfont(1, gui.font, gui.fontSize*0.9, string.byte('i'))
	gfx.x = gfx.w  - margin
	drawString("Left Click and drag (setting color on mouse release). To reset to default color, release on this upper area", "right")

	-- seperator
	gfx.set(table.unpack(gui.textColor)); gfx.a=0.2
	gfx.line(0,imageMarginTop - 5, gfx.w, imageMarginTop - 5)
	-- image swatch
	gfx.x = margin
	gfx.y = imageMarginTop
	gfx.a = 1
	gfx.blit(image,1,0)
end

function clickDraw()
	gfx.set(table.unpack(gui.textColor)); gfx.a=0.2
	gfx.line(0,imageMarginTop - 5, gfx.w, imageMarginTop - 5)
	gfx.x = margin
	gfx.y = imageMarginTop
	gfx.a = 1
	gfx.blit(image,1,0)

	-- gfx.x = 100
	-- gfx.y = 100
	-- fdebug("lclick")
	-- gfx.x = gfx.mouse_x
	-- gfx.y = gfx.mouse_y
	-- red = 0
	-- green = 0
	-- blue = 0
	color = gfx.getpixel(red, green, blue)
	gfx.x = margin
	gfx.y = margin
	if (gfx.mouse_y > imageMarginTop) then
		gfx.x = gfx.mouse_x
		gfx.y = gfx.mouse_y
		r,g,b = gfx.getpixel()
		gfx.set(r,g,b)
		r = math.floor(r*255)
		g = math.floor(g*255)
		b = math.floor(b*255)
		gfx.y = margin
		gfx.x = margin

		gfx.rectto(gfx.x+20, gfx.y+20)
		gfx.set(table.unpack(gui.textColor))
		gfx.setfont(1, gui.font, gui.fontSize, string.byte('b'))
		gfx.y = textTop
		gfx.x = gfx.x + textSpacing
		drawString(context)
		gfx.setfont(1, gui.font, gui.fontSize)
		drawString(": set to RGB (".. r .."," .. g .. "," .. b ..")")
		colorize(true, r, g, b)
	else
		gfx.y = textTop
		gfx.x = margin + 20 + textSpacing
		-- gfx.set(gui.textColor)
		gfx.setfont(1, gui.font, gui.fontSize, string.byte('b'))
		drawString(context)
		gfx.setfont(1, gui.font, gui.fontSize)
		drawString(": reset to default color")
		colorize(false)
	end
end

function release()
	-- gfx.update()
	gfx.x = gfx.mouse_x
	gfx.y = gfx.mouse_y
	drawString("Goodnight")	
	exit = true
	-- colorize(true)
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
		-- fdebug(red)
	end
	gfx.update()
	local c=gfx.getchar()
	-- it's -1 when closed, and 27 at ESC
	-- fdebug(c)
	if c>=0 and c~=27 and not exit then
		reaper.defer(mainloop)
	end
end

reaper.atexit(
	function()
		fdebug("at exit")
		TcpRedraw()
		reaper.Undo_EndBlock(label, -1)
	end
	)

reaper.Undo_BeginBlock()
init()
mainloop()