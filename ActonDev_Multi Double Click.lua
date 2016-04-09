package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path .. "\n")
require 'ActonDev.deps.template'
require 'ActonDev.deps.region'

debug_mode = 0

function main()
	reaper.Undo_BeginBlock()
	selItem = reaper.GetSelectedMediaItem(0, 0)
	selTrack = reaper.GetMediaItemTrack(selItem);

	_,chunk =  reaper.GetItemStateChunk(selItem, "", 0)
	-- fdebug(chunk)
	itemType = string.match(chunk, "<SOURCE%s(%a%a%a%a).*\n")
	-- fdebug(itemType)
	if itemType == "MIDI" then
		-- built-in midi editor
		label = "ActonDev: Open Midi item"
		reaperCMD("40153")
	elseif itemType == "WAVE" then
		label = "ActonDev: Open Wave item"
		reaperCMD("40009")
	else
		-- "folder/region" empty item
		reaper.PreventUIRefresh(1)

		reaperCMD("_SWS_SAVETIME1")
		regionItemSelect(selItem)

		-- select only our initially selected track
		reaper.SetOnlyTrackSelected(selTrack);

		reaperCMD("_SWS_RESTTIME1")
		-- refresh ui, create undo point
		label = "ActonDev: Select Folder item"
		reaper.PreventUIRefresh(-1)
	end

	-- fdebug(getExtState("MediaItemGarbageGUID"))

	reaper.Undo_EndBlock(label, -1) 

end

if(reaper.CountSelectedMediaItems(0) > 0) then
	main()
end