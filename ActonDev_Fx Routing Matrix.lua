-- Original script: eugen2777. HUGE APPRECIATION ABOUT THIS!

package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path)
require 'ActonDev.deps.template'
require 'ActonDev.deps.colors'
require 'ActonDev.deps.class'
require 'ActonDev.deps.GuiBuffer'
require 'ActonDev.deps.drawing'
debug_mode = 1

label = "ActonDev: Fx Routing Matrix"

local gui = {}
local colors = {}

function scriptColors()
	gfx.clear = themeColor("col_main_bg2")
	colors.back = {themeColor("col_main_bg2", true)}
	colors.text = {themeColor("col_main_text2", true)}

	colors.left = {themeColor("col_mi_bg2", true)}
	-- colors.right = {themeColor("region", true)}

	local scale = 1.2
	colors.right = {colorAdjust(colors.left[1], colors.left[2], colors.left[3], 0.2)}
	colors.odd = {colorAdjust(colors.text[1], colors.text[2], colors.text[3], 0)}

	local adjust = 0.05
	colors.odd = {colorAdjust(colors.back[1], colors.back[2], colors.back[3], adjust)}
	colors.even = {colorAdjust(colors.back[1], colors.back[2], colors.back[3], -adjust)}

	colors.highlightRow = {colorAdjust(colors.back[1], colors.back[2], colors.back[3], 3*adjust)}

	colors.frameBorder = {themeColor("col_main_3dsh",true)}

	colors.labelBack = {themeColor("col_main_text2", true)}
	colors.labelBack = colors.text
	colors.labelText = {themeColor("col_main_bg2", true)}
	colors.labelText = colors.back
end

function init()
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	---INIT---------------------------------------------------------------------------------------------
	Z = 18 --used as cell w,h(and for change zoom level etc)
	R = 1  --used for rewind FXs

	scrollX = 0
	scrollStep = 80

	alphaBypass = 0.7

	scriptColors()

	gui.font = "Calibri"

	-- 200 height handels 6 channels, nice optically
	gfx.init(label, 800,300 )

	
	gfx.setfont(1,gui.font, Z)
	last_mouse_cap=0
	mouse_dx, mouse_dy =0,0

	reaperCMD("_BR_MOVE_WINDOW_TO_MOUSE_H_M_V_B")
end



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function pointIN(x,y,w,h)
	return mouse_ox >= x and mouse_ox <= x + w and mouse_oy >= y and mouse_oy <= y + h and
	gfx.mouse_x >= x and gfx.mouse_x <= x + w and gfx.mouse_y  >= y and gfx.mouse_y <= y + h
end

function mouseOver(x,y,w,h)
	return gfx.mouse_x >= x and gfx.mouse_x <= x + w and gfx.mouse_y  >= y and gfx.mouse_y <= y + h
end
-----
function mouseClick()
	return gfx.mouse_cap&1==0 and last_mouse_cap&1==1
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
---draw current pin---------------------------------------------------------------------------------
function draw_pin(track,fx,isOut,pin,chans, x,y,w,h, alphaIn)
	local Low32,Hi32 = reaper.TrackFX_GetPinMappings(track, fx, isOut, pin)--Get current pin
	local bit,val
	local Click = mouseClick()
	gfx.a=1
	local color1 = colors.text[1]
	local color2 = colors.text[2]
	local color3 = colors.text[3]
	gfx.set(color1,color2,color3)
	if (pin+1)%2==0 then
		-- gfx.a=1
		-- local color = colorAdjust(color1,color2,color3)
		gfx.set(table.unpack(colors.right))
	else
		gfx.set(table.unpack(colors.left))
	end
	--set pin color(odd parity) 
	--------------------------------------
	--draw(and change val if Clicked)-------
	for i = 1, chans do
		bit = 2^(i-1)       --cuurent bit
		val = (Low32&bit)>0 --current bit(aka channel value as booleen)
		if Click and pointIN(x+select(1,fxBuffer:clickOffset()),y+select(2,fxBuffer:clickOffset()),w,h) then
			if val then
				Low32 = Low32 - bit
			else
				Low32 = Low32 + bit
			end 
			reaper.TrackFX_SetPinMappings(track, fx, isOut , pin, Low32, Hi32)--Set pin 
		end

		gfx.a = alphaIn
		-- border
		gfx.rect(x,y,w-2,h-2, 0)
		-- fill
		if val then gfx.rect(x+1,y+1,w-4,h-4, 1) end
		y = y + h --next y
	end 
	--------------------------------------
	return x,y
end

function calcWindowWidth(track)

end

---draw_FX_labels-----------------------------------------
function draw_FX_labels(track, fx, x, y, w, h)
	local _, fx_name = reaper.TrackFX_GetFXName(track, fx, "");
	fx_name = " ".. string.gsub(fx_name, "[VSTiJS]+: ", "")
	local _, in_Pins,out_Pins = reaper.TrackFX_GetIOSize(track,fx)
	if out_Pins==-1 and in_Pins~=-1 then out_Pins=in_Pins end --in some JS outs ret "-1" 

	w,h = w*(in_Pins+out_Pins+1.2)-2,h-1 --correct values for label position
	local s_w, s_h = gfx.measurestr(fx_name)
	local maxChars = math.floor(w/gfx.measurestr("E"))
	if fx_name:len() > maxChars then
		fx_name = fx_name:sub(1, maxChars-1)..".."
	end
	local fxEnabled = reaper.TrackFX_GetEnabled(track,fx)
	-----------------------
	gfx.x, gfx.y = x, y+(h-gfx.texth)/2
	gfx.set(colors.labelBack[1], colors.labelBack[2], colors.labelBack[3])
	gfx.rect(x,y,w,h,fxEnabled)
	if fxEnabled then
		gfx.set(colors.labelText[1], colors.labelText[2], colors.labelText[3])
	end
	gfx.printf(fx_name)
	
	-- Fx label click
	if mouseClick() and pointIN(x+select(1,fxBuffer:clickOffset()),y+select(2,fxBuffer:clickOffset()),w,h) then
		if Shift then
			-- Toggle Bypass
			reaper.TrackFX_SetEnabled(track, fx, not fxEnabled)
		elseif Alt then
			-- Remove Fx
			reaper.SNM_MoveOrRemoveTrackFX(track, fx, 0)
		else
			-- normal click, open Fx window
			reaper.TrackFX_SetOpen(track, fx, not reaper.TrackFX_GetOpen(track, fx) )--not bool for change state
			-- sleep(1)
			reaperCMD("_BR_MOVE_WINDOW_TO_MOUSE_H_M_V_T")
		end
	end
	return x, y
end
--------------------------------------------------------



---draw current FX--------------------------------------
function draw_FX_pins(track, fx, chans, x,y,w,h, alphaTrack)
	local _, in_Pins,out_Pins = reaper.TrackFX_GetIOSize(track,fx) 
	--for some JS-plug-ins---------------------------------
	if out_Pins==-1 and in_Pins~=-1 then out_Pins=in_Pins end --in some JS outs ret "-1" 

	local enabled, alphaFX
	if reaper.TrackFX_GetEnabled(track,fx) then
		alphaFX = 1
	else
		alphaFX = alphaBypass
	end

	local alpha = math.min(alphaTrack,alphaFX)

	---------------------------------
	--------------------------------
	--Draw FX pins,chans etc-- 
	---------------
	--input pins---
	local tempY, maxY = 0,0
	y=y+1.5*w
	local isOut=0
	for i=1,in_Pins do
		draw_pin(track,fx,isOut, i-1,chans, x,y,w,h, alpha)--(track,fx,isOut, pin,chans, x,y,  w,h)
		x = x + w --next x
	end
	---------------
	x = x + 1.2*w --Gap between FX in-out pins
	---------------
	--output pins--
	local isOut=1 
	for i=1,out_Pins do
		_,tempY = draw_pin(track,fx,isOut, i-1,chans, x,y,w,h, alpha)--(track,fx,isOut, pin,chans, x,y,  w,h)
		maxY = math.max(maxY, tempY)
		x = x + w --next x
	end   
	return x,maxY --return x value for next FX position
end

function draw_rows(chans, x, y, w, h)
	gfx.x, gfx.y = x, y
	local tempY=y+0.5*w
	-- gfx.a=0.15
	-- gfx.set(table.unpack(colors.odd))
	for i=1,chans,2 do
		gfx.set(table.unpack(colors.odd))
		-- if gfx.mouse_y  >= tempY and gfx.mouse_y <= tempY + h then
		if mouseOver(0,tempY,gfx.w,h) then
			gfx.set(table.unpack(colors.highlightRow))
		end
		gfx.rect(0,tempY-1,gfx.w,h-1, 1)
		tempY = tempY + 2*h
	end
	tempY=y+1.5*w
	
	for i=2,chans,2 do
		gfx.set(table.unpack(colors.even))
		-- if gfx.mouse_y  >= tempY and gfx.mouse_y <= tempY + h then
		if mouseOver(0,tempY,gfx.w,h) then
			gfx.set(table.unpack(colors.highlightRow))
		end
		gfx.rect(0,tempY-1,gfx.w,h-1, 1)
		tempY = tempY + 2*h
	end
end

--draw in-out +/- buttons-----------------------
function draw_track_chan_add_sub(track,chans, x,y,w,h)
	-- y=y+0.5*h
	gfx.set(table.unpack(colors.text))
	-- "-" --
	-- Remove channels
	gfx.rect(x,y,w-2,h-2, 0)
	local s_w, s_h = gfx.measurestr("-")
	gfx.x, gfx.y = x + (w-1.2*s_w)/2 , y + (h-1.2*s_h)/2 
	gfx.printf("-")
	-- y = y + h
	if mouseClick() and pointIN(x,y,w,h) then reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", math.max(chans-2,2))  end 

	-- "+" --
	-- Add channels
	y = y+h
	gfx.rect(x,y,w-2,h-2, 0);
	s_w, s_h = gfx.measurestr("+")
	gfx.x, gfx.y = x + (w-1.2*s_w)/2 , y + (h-1.2*s_h)/2 
	gfx.printf("+")
	
	if mouseClick() and pointIN(x,y,w,h) then reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", math.min(chans+2,32)) end 
	return x+w
end
------------------------------------------------
---draw track in/out----------------------------
function draw_track_in_out(type,track,chans, x,y,w,h)
	gfx.x, gfx.y = x, y-w
	gfx.set(table.unpack(colors.text))
	gfx.printf(type)
	y=y+0.5*w
	for i=1,chans do 
		if i%2==0 then
			gfx.set(colors.right[1], colors.right[2], colors.right[3])
		else 
			gfx.set(colors.left[1], colors.left[2], colors.left[3])
		end
		gfx.rect(x,y,w-2,h-2, 1)
		gfx.set(table.unpack(colors.back))
		if i < 10 then gfx.x =x+4 else gfx.x =x end
		-- drawString(i, "center", x,y,w,h)
		 gfx.y =y-1
		 gfx.printf(i)
		y = y + h
	end
	return x,y
end

function draw_FX_enabled(track, enabled, x, y, w, h)
	local statusText
	gfx.rect(x,y,w-2,h-2, 0)
	if(enabled == 1) then
		statusText = " ON"
		gfx.rect(x+2,y+2,w-6,h-6, 1)
	else
		statusText = "OFF"
	end

	gfx.x = x + 1.2*w
	gfx.y=y
	gfx.printf(statusText)
	if mouseClick() and pointIN(x,y,w,h) then
		-- gfx.w = 300
		if enabled == 0 then enabled = 1 else enabled = 0 end
		reaper.SetMediaTrackInfo_Value(track, "I_FXEN", enabled)
	end
end

function draw_FX_add(x,y, w, h)
	local text = " Add FX "
	local s_w, s_h = gfx.measurestr(text)
	x = x
	y=y+2
	gfx.x = x
	gfx.y = y
	
	-- gfx.y = y-2*w
	gfx.set(table.unpack(colors.text))
	gfx.rect(x,y,s_w,s_h, 1)
	gfx.set(table.unpack(colors.back))
	gfx.printf(text)
	if mouseClick() and pointIN(x,y,s_w,s_h) then
		-- open FX browser
		reaperCMD(40271)
		reaperCMD("_BR_MOVE_WINDOW_TO_MOUSE_H_M_V_T")
	end
end
------------------------------------------------

function drawFrame(x,y,w,h)
	gfx.mode = 0
	gfx.set(table.unpack(colors.text))
	gfx.a = 0.05
	gfx.rect(x,y,w,h, 1)
	gfx.mode=0
	gfx.a=1
	gfx.set(table.unpack(colors.frameBorder))
	drawRectBorder(x,y,w,h,1)
end



fxBuffer = GuiBuffer(1)

function drawScrollbar(x,y,w,h)
	if( select(1,fxBuffer:outSize()) < select(1,fxBuffer:inSize()) ) then

		gfx.set(table.unpack(colors.text))
		gfx.a=0.5
		-- gfx.rect(x,y,w,h)
		drawRectBorder(x,y,w,h,1)
		-- gfx.set(table.unpack(colors.odd))
		local scrollRatio = math.min(1,select(1,fxBuffer:outSize())/select(1,fxBuffer:inSize()))
		-- fdebug("Scroll ration ".. scrollRatio)
		gfx.rect(x+scrollX*scrollRatio,y,w*scrollRatio,h)
		gfx.a=1
	end
end

---Main DRAW function---------------------------
lastTrack = nil
function DRAW()
	x=0
	y=0

	
	fxBuffer:clear()
	fxBuffer:setScroll(scrollX)
	local w,h = Z,Z --its only one chan(rectangle) w and h (but it used in all calculation)
	local x,y = w, 0.5*w  --its first pin of first FX    x and y (but it used in all calculation) 
	local tempY -- for storing where drawing ended in y, used in +,- buttons so they snap at the last channel
	local M_Wheel
	----
	gfx.set(colors.text[1], colors.text[2], colors.text[3])
	local track = reaper.GetSelectedTrack(0, 0)
	if lastTrack ~= track then scrollX = 0 end
	lastTrack = track
	if track then
		local trackId = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
		local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
		local fx_count = reaper.TrackFX_GetCount(track)
		local chans = math.min( reaper.GetMediaTrackInfo_Value(track, "I_NCHAN"), 32 ) -- max value for visible chans
		--------------------------------------------------------
		--------------------------------------------------------
		---Zoom------
		if Ctrl and not Shift then
			M_Wheel = gfx.mouse_wheel;gfx.mouse_wheel = 0
			if M_Wheel>0 then
				-- Z = math.min(Z+1, 30)
			elseif M_Wheel<0 then
				-- Z = math.max(Z-1, 8)
			end
			gfx.setfont(1,gui.font, Z)
		end
		---Rewind---
		if Shift and not Ctrl then
			M_Wheel = gfx.mouse_wheel;gfx.mouse_wheel = 0
			if M_Wheel<0 then
				R = math.min(R+1, fx_count)
			elseif M_Wheel>0 then
				R = math.max(R-1, 1)
			end
			gfx.setfont(1,gui.font, Z)
		end

		if not Shift and not Ctrl then
			M_Wheel = gfx.mouse_wheel;gfx.mouse_wheel = 0
			if M_Wheel<0 then
				scrollX = scrollX + scrollStep
			elseif M_Wheel>0 then
				scrollX = math.max(scrollX-scrollStep, 0)
			end
		end
		--------------------------------------
		--draw track info(name,fx count etc)--
		gfx.x, gfx.y = w, h

		local alpha = 1
		local fxEnabled = reaper.GetMediaTrackInfo_Value(track, "I_FXEN")
		if fxEnabled == 0 then
			alpha = 0.7
		end

		draw_FX_enabled(track,fxEnabled, 0.5*w,y,w,h)

		gfx.x, gfx.y = 4*w, y
		if track_name:len()>0 then track_name = "\""..track_name.."\"" end
		gfx.printf("Track " .. math.floor(trackId) .. "  ".. track_name.."  |  FXs: "..fx_count .. "   |    ")

		draw_FX_add(gfx.x, gfx.y, w, h)
		y = gfx.y+3*h

		-- gfx.printf("Add")
		--------------------------------------
		--draw track in,chan_add_sub----------
		
		draw_rows(chans,x,y,w,h)
		gfx.x, gfx.y = x, h
		
		x, tempY = draw_track_in_out("IN", track,chans, x+w,y,w,h)
		draw_track_chan_add_sub(track,chans, x-1.5*w,tempY-h,w,h)
		x=x+1.5*w
		
		-- drawing on FX buffer (to make it scrollable)
		gfx.dest = 1
		local fx_x,fx_y = 0,0
		-- local tempY = 0
		for i=1, fx_count do --R = 1-st drawing FX(used for rewind FXs)
			fx_x = draw_FX_labels(track, i-1, fx_x, fx_y, w, h, alpha)
			fx_x, tempY = draw_FX_pins(track, i-1,chans, fx_x, 0, w, h,alpha) -- offset for next FX
			fx_x = fx_x + w
		end

		-- setting actual drawn size (to calculate maxScroll)
		-- 		adding some padding to make it work with scrollStep size
		fxBuffer:setInSize(math.floor(fx_x-w), tempY)

		-- drawing back on on-screen buffer
		gfx.dest = -1;
		
		draw_track_in_out("OUT",track,chans, gfx.w-2*w,y,w,h)
		----------------------------
		-- gfx.a=1
		
	else
		-- track nill
		gfx.x, gfx.y = 4*w, h; gfx.printf("No selected track!") 
	end
	-- gfx.update()
	gfx.dest = -1
	gfx.x=0;gfx.y=0
	gfx.mode = 0

	fx_start_x, fx_start_y = 4*w, 2.5*w

	fxBuffer:setOutStart(fx_start_x, fx_start_y)

	fx_end_x, fx_end_y = gfx.w -3*w, gfx.h
	fxBuffer:setOutEnd(fx_end_x, fx_end_y)
	scrollX = math.min(scrollX, fxBuffer:maxScrollX(scrollStep))
	-- fxBuffer.setOutSize(fx_start_x)
	gfx.x = fx_start_x
	gfx.y = fx_start_y
	drawFrame(fx_start_x-5, fx_start_y-8, select(1,fxBuffer:outSize())+10, select(2,fxBuffer:inSize())+10)
	gfx.blit(fxBuffer:getId(),1,0,scrollX,0, select(1,fxBuffer:outSize()), select(2,fxBuffer:outSize()))
	drawScrollbar(fx_start_x, fx_start_y + select(2,fxBuffer:inSize())+10, select(1,fxBuffer:outSize()), 13)
	-- gfx.update()
end

---------------------------------------
function mainloop()
	
	if gfx.mouse_cap&1==1 and last_mouse_cap&1==0 then 
		mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y 
	end
	Ctrl  = gfx.mouse_cap & 4 == 4
	Shift = gfx.mouse_cap & 8 == 8
	Alt = gfx.mouse_cap & 16 == 16

	----------------------
	--MAIN DRAW function--
	checkThemeChange()
	DRAW()
	----------------------
	----------------------
	last_mouse_cap = gfx.mouse_cap
	last_x,last_y = gfx.mouse_x,gfx.mouse_y

	gfx.update()

	local c = gfx.getchar()
	if c~=-1 and c ~=27 then
		reaper.defer(mainloop)
	end
end
---------------------------------------
-------------


init()
mainloop()

