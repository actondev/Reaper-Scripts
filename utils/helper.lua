local helper = {}

function helper.reaperCMD(id)
	if type(id) == "string" then
		reaper.Main_OnCommand(reaper.NamedCommandLookup(id),0)
	else
		reaper.Main_OnCommand(id, 0)
	end
end

return helper;