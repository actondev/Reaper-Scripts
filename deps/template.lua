ActonDev = {}

debug_mode = 0
function reaperCMD(id)
	if type(id) == "string" then
		reaper.Main_OnCommand(reaper.NamedCommandLookup(id),0)
	else
		reaper.Main_OnCommand(id, 0)
	end
end

debug_mode = 1
function fdebug(str)
	if debug_mode==1 then
		if str ~= nil then
			reaper.ShowConsoleMsg(os.date() .. "   " .. tostring(str) .. "\n")
		else
			reaper.ShowConsoleMsg(os.date().. "   NILL!\n")
		end
	end
end

function getExtState(key)
	local ret
	_, ret = reaper.GetProjExtState(0, "ActonDev", key)
	return ret
end

function setExtState(key, value)
	reaper.SetProjExtState(0, "ActonDev", key, value)
end

function appendExtState(key, value)
local prevValue = getExtState(key)
local newValue = prevValue .. value .. ";"
setExtState(key, newValue)
end

function fileExists(name)
	local f=io.open(name,"r")
	if f~=nil then
		-- fdebug(name .. " EXISTS")
		io.close(f)
		return true
	else
		-- fdebug(name .. " DOESNT EXIST")
		return false
	end
end

-- this is bad as it turned out (freezing the whole reaper gui).. do not use for now
function sleep(n)  -- seconds
  local t0 = os.clock()
  while os.clock() - t0 <= n do end
end

function boolToDialog(value)
	-- input: false, or true
	-- returns corresponding value in messageBoxDialog (yes, no)
	-- 6 responds to YES in the dialog
	-- 2 responds to NO in the  dialog
	if value == true then
		return 2
	elseif	value == false then 
		return 6
	else
		-- value probably nil => handle the 0 to prompt user
		return nil
	end
end
