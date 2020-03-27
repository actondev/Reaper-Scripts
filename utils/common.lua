local module = {}

function module.cmd(id)
	if type(id) == "string" then
		reaper.Main_OnCommand(reaper.NamedCommandLookup(id),0)
	else
		reaper.Main_OnCommand(id, 0)
	end
end

function module.undoBeginBlock()
    reaper.Undo_BeginBlock()
end

function module.undoEndBlock(undoMsg)
    -- extra parameter: extra flags.. what is -1 for?
    reaper.Undo_EndBlock(undoMsg, -1)
end

function module.preventUIRefresh(prevent_count)
    reaper.PreventUIRefresh( prevent_count)
end

function module.updateArrange()
    reaper.UpdateArrange()
end

return module