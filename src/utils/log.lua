local module = {}

module.isdebug = false

function module.debug(str)
	if module.isdebug==true then
		if str ~= nil then
			reaper.ShowConsoleMsg(os.date() .. "   " .. tostring(str) .. "\n")
		else
			reaper.ShowConsoleMsg(os.date().. "   NILL!\n")
		end
	end
end

function module.dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. module.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

return module;