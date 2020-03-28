local module = {}

local THEME_FILE_FALLBACK = debug.getinfo(1,'S').source:match("@(.+)[/\\].+$").. "/../resources/Default_5.0_unpacked.ReaperTheme"

local function fileExists(name)
	local f=io.open(name,"r")
	if f~=nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- TODO what's that vs the reaper.GetLastColorThemeFile() ?
function module.file()
    local fileName = reaper.GetLastColorThemeFile()
    local extension = string.match(fileName, "%.(%a+)$")
    if fileExists(fileName) then
        return fileName
    else
        return nil
    end
end

--[[
    also check
    themePath, themeName = reaper.BR_GetCurrentTheme()
]]
function module.content(themeFile)
	if themeFile == nil then
		themeFile = THEME_FILE_FALLBACK
	end
    if fileExists(themeFile) then
        local theme = io.open(themeFile, "r")
        -- ActonDev.themeError = false
        local themeContent = theme:read("*a")
        io.close(theme)
        return themeContent
    else
        return nil
    end
end

-- returns the theme color r, g, b
-- the rgb is in [0-1] range
local function color(themeContent, key, isRgb)
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

	-- ini file alternative.. reaper.ini does not get update on theme change?
	-- local inipath = reaper.get_ini_file()
	-- local ret, stringOut = reaper.BR_Win32_GetPrivateProfileString("color theme", key, "", inipath)
	-- fdebug("HERE " .. key)
	-- fdebug(ret)
	-- fdebug(stringOut)
	-- local color = stringOut


	local color = string.match(themeContent, key.."=([%-%d]+)\n")

	color = tonumber(color,10)
	if color<0 then 
		color = color + 2147483648
	end
	if isRgb then
		local r;local g; local b
		r,g,b = reaper.ColorFromNative(color)
		r = r/255; g=g/255; b=b/255
		return r,g,b
	else
		return color
	end
end

function module.colorSingle(themeContent, key)
	return color(themeContent, key, false)
end

function module.colorRGB(themeContent, key)
	return color(themeContent, key, true)
end

function module.colorFromIni(key)
	local ret, stringOut = reaper.BR_Win32_GetPrivateProfileString("color theme", key, "", reaper.get_ini_file())
	color = tonumber(stringOut,10)
	if color<0 then
		color = color + 2147483648
	end
	-- if rgb then
		local r;local g; local b
		r,g,b = reaper.ColorFromNative(color)
		r = r/255; g=g/255; b=b/255
		return r,g,b
end

return module
