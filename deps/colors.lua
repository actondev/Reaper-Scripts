ActonDev.themeContent = nil
ActonDev.themeFileName = ""
ActonDev.themeError = nil
ActonDev.themeFileNameFallback = debug.getinfo(1,'S').source:match("@(.+)[/\\].+$").. "/Default_5.0_unpacked.ReaperTheme"
-- package.config:sub(1,1) is the os path separator
ActonDev.themeFileNameFallback = string.gsub(ActonDev.themeFileNameFallback, "/", package.config:sub(1,1))
updateColorsCallback = nill

-- if flag colorize to r,g,b
-- if false, reset to default color
-- depends on the cursor context (tracks or items)
function colorize(flag, r, g, b)
	local writeValue = 0
	if flag then
		local colorNative = reaper.ColorToNative(r,g,b)
		writeValue = colorNative|0x1000000
	end
	
	if reaper.GetCursorContext2(true) == 1 and reaper.CountSelectedMediaItems(0)>0 then
		-- coloring the items
		local nItems = reaper.CountSelectedMediaItems(0)
		for i=0,nItems-1 do
			local item = reaper.GetSelectedMediaItem(0,i)
			local nTakes = reaper.GetMediaItemNumTakes(item)
			if nTakes>0 then
				local take = reaper.GetActiveTake(item)
				reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR", writeValue)
			else
				reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", writeValue)
			end
		end
	else
		-- coloring the tracks
		local nTracks = reaper.CountSelectedTracks(0)
		for i=0,nTracks-1 do
			local track = reaper.GetSelectedTrack(0,i)
			reaper.SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", writeValue)
		end
	end
	reaper.UpdateArrange()
end

function hue2RGB(p, q, t)
	if t < 0 then
		t = t + 1
	elseif t > 1  then
		t = t - 1
	end
	if t < 1/6 then
		return p + (q - p) * 6 * t
	end
	if t < 1/2 then
		return q
	end
	if t < 2/3  then
		return p + (q - p) * (2/3 - t) * 6
	end
	return p
end

-- Functional-if


function RGB2HSL(R,G,B)
	-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
	function fif(condition, if_true, if_false)
		if condition then return if_true else return if_false end
	end
	-- inputs R,G,B: 0-1 range
	-- H: Hue
	-- S: Saturation
	-- L: Lightness
	local max = math.max(R,G,B)
	local min = math.min(R,G,B)
	local H,S,L
	H=(max+min)/2;S=H;L=H

	if max == min then
		-- achromatic
		H = 0
		S = 0
	else
		local d = max-min
		-- calculating S
		-- Functional-if
		S = fif(L>0.5, d/(2-max-min), d/(max+min) )
		-- switch max
		if max == R then
			H = (G - B) / d + fif(G < B,6,0)
		elseif max == G then
			H = (B-R)/d+2
		else
			H = (R-G)/d + 4
		end
		-- calculating H
		H = H/6;
	end
	return H,S,L
end

function HSL2RGB(H,S,L)
	-- R,G,B outputs: 0-1 range
	function fif(condition, if_true, if_false)
		if condition then return if_true else return if_false end
	end

	local R, G, B
	if S == 0 then
		R=L;G=L;B=L
	else
		local q = fif(L<0.5, L*(1+S), L+S-L*S)
		local p = 2*L - q
		R = hue2RGB(p, q, H+1/3)
		G = hue2RGB(p, q, H)
		B = hue2RGB(p, q, H-1/3)
	end
	return R,G,B
end

function colorDebug(text,c1,c2,c3)
	-- if c1 == nil then c1 = 0 end
	-- if c2 == nil then c2 = 0 end
	-- if c3 == nil then c3 = 0 end
	if string.match(text, "%P%P%P") == "RGB" and c1<=1 and c2<=1 and c3<=1 and true then
		c1=c1*255;c2=c2*255;c3=c3*255
	end
	fdebug(text .. " (" .. c1 .. ", " .. c2 .. ", ".. c3 .. ")")
end

function colorAdjust(R,G,B,adjust)
	-- colorDebug("RGB input",R,G,B)
	local H,S,L = RGB2HSL(R,G,B)
	-- colorDebug("HSL",H,S,L)
	L=L+adjust
	if L>1 then
		L=1
	elseif L<0 then
		L=0
	end
	R,G,B = HSL2RGB(H,S,L)
	-- colorDebug("RGB plus " .. adjust,R,G,B)
	return R,G,B
end

function getThemeFileName()
	local fileName = reaper.GetLastColorThemeFile()
	local extension =  string.match(fileName,"%.(%a+)$")
	if fileExists(fileName) then
		return fileName, true
	else
		fileExists(ActonDev.themeFileNameFallback)
		-- it resets values/ reruns the script?
		
		return ActonDev.themeFileNameFallback, false
	end
end

function checkThemeChange()
	if reaper.GetLastColorThemeFile() ~= ActonDev.themeFileName then
		ActonDev.themeFileName = reaper.GetLastColorThemeFile()
		-- fdebug(ActonDev.themeFileName)
		if fileExists(ActonDev.themeFileName) then
			local theme = io.open(ActonDev.themeFileName, "r")
			-- ActonDev.themeError = false
			ActonDev.themeContent = theme:read("*a")
			io.close(theme)
		else
			-- reaper.ShowMessageBox("Please unpack your current theme, so that .ReaperTheme file is readable", "Error", 0)
			local theme = io.open(ActonDev.themeFileNameFallback, "r")
			-- ActonDev.themeError = false
			ActonDev.themeContent = theme:read("*a")
			io.close(theme)
			ActonDev.themeError = true
		end

		if type(scriptColors) == "function" then
			scriptColors()
		end
	end
end

function themeColor(key, rgb)
	-- if rgb == false, it returns the corresponding value from .ReaperTheme
	-- 		example value: 2960685
	-- if rgb == true, returns r,g,b values at [0-1] range
	-- 		example: 0.2, 0.5654, 0.332

	


	-- window background: col_main_bg
	-- Main window/transport text: col_main_text2
	-- Main window/transport background: col_main_bg2 
	-- window eidt background: col_main_editbk
	-- Toolbar frame: col_toolbar_frame (meh)
	-- Track background (odd tracks): col_tr1_bg
	-- Track panel text: col_tcp_text
	-- Unselected track control panel background: col_seltrack2
	-- Selected track control panel background: col_seltrack
	-- Empty arrange view area: col_arrangebg
	-- Media item background (odd): col_mi_bg2

	if ActonDev.themeContent == nil then checkThemeChange() end
	if rgb == nil then rgb = false; end
	

	-- ini file alternative.. reaper.ini does not get update on theme change?
	-- local inipath = reaper.get_ini_file()
	-- local ret, stringOut = reaper.BR_Win32_GetPrivateProfileString("color theme", key, "", inipath)
	-- fdebug("HERE " .. key)
	-- fdebug(ret)
	-- fdebug(stringOut)
	-- local color = stringOut


	local color = string.match(ActonDev.themeContent,key.."=([%-%d]+)\n")

	color = tonumber(color,10)
	if color<0 then 
		color = color + 2147483648 
	end
	if rgb then
		local r;local g; local b
		r,g,b = reaper.ColorFromNative(color)
		r = r/255; g=g/255; b=b/255
		return r,g,b
	else
		return color
	end
end

-- if colorizing a track, rtconfig "tcp.trackidx.color ?trackcolor_valid" does not work,
-- 		gotta redraw/update the TCP (Track Control Panel)
function TcpRedraw()
	-- credits: found in a X-Raym script, crediting HeDa in turn.. thanks both! :D
	reaper.PreventUIRefresh(1)
	local track=reaper.GetTrack(0,0)
	local trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")	
	if trackparam==0 then
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
	else
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
	end
	reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)
	reaper.PreventUIRefresh(-1)
end