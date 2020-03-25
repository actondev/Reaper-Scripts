local log = {}

log.isdebug = false

function log.debug(str)
	if log.isdebug==true then
		if str ~= nil then
			reaper.ShowConsoleMsg(os.date() .. "   " .. tostring(str) .. "\n")
		else
			reaper.ShowConsoleMsg(os.date().. "   NILL!\n")
		end
	end
end

function log.dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. log.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

return log;