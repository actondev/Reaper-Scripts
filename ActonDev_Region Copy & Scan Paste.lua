package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path)
require 'ActonDev.deps.template'
require 'ActonDev.deps.region'

debug_mode = 0

regionItems = {}
label = 'ActonDev: Copy Region'

function copyItems()
	-- split items at time selection
  reaperCMD(40061)
  -- copy items
  reaperCMD(40698)
end

-- item, notes are the source item, source notes
function scanPaste(targetRegionItems, sourceItem, sourceNotes)
	for i=1,#targetRegionItems do
		local tempItem = targetRegionItems[i]
		-- if sourceItems are multiple, some items have been deleted (and pasted over)
		-- so these items have been set to nil
		if tempItem ~= nil then
			_,chunk =  reaper.GetItemStateChunk(tempItem, "", 0)
			fdebug(i .. " type " .. type(tempItem))
			fdebug(chunk)
			local tempNotes = reaper.ULT_GetMediaItemNote(tempItem)
			fdebug(i .."#   " .. tempNotes)
			if tempItem == sourceItem then
				-- it's our initial region item, whose region we want to copy
				fdebug("    :::IGNORE:::")
			elseif tempNotes == sourceNotes then
				fdebug("    :::PASTE:::")
				targetRegionItems[i] = nil
				-- paste here
				affected = affected + 1
				-- Unselect all items
				reaperCMD(40289)
				reaper.SetMediaItemSelected(tempItem, 1)
				-- reaper.SetOnlyTrackSelected(selTrack)
				regionItemSelect(tempItem, false)
				-- remove items
				reaperCMD(40006)
				-- paste
				reaperCMD(40058)
				mediaItemGarbageCleanSelected()
			end
		end
	end
end

affected = 0


function doRegionItems(sourceRegionItems, targetRegionItems)
	fdebug("region items here: " .. #sourceRegionItems)
	local i
	for  i = 1, #sourceRegionItems do
		local sourceItem = sourceRegionItems[i]
		-- selTrack = reaper.GetMediaItemTrack(selItem)
		local sourceNotes = reaper.ULT_GetMediaItemNote(sourceItem)
		-- IMPORTANT: here second argument (unselect), must be true
		regionItemSelect(sourceItem, true)
		copyItems()
		scanPaste(targetRegionItems, sourceItem, sourceNotes)
	end
end


function main()
	reaper.Undo_BeginBlock()
	local selItem = reaper.GetSelectedMediaItem(0, 0)
	local selTrack = reaper.GetMediaItemTrack(selItem)
	reaper.SetOnlyTrackSelected(selTrack)

	reaper.PreventUIRefresh(1)

	reaperCMD("_SWS_SAVETIME1")
	reaperCMD("_SWS_SAVEVIEW")
	reaperCMD("_BR_SAVE_CURSOR_POS_SLOT_1")
	-- save selected region items
	local sourceRegionItems = getRegionItems()
	-- select all items in track
	reaperCMD(40421)
	-- save all region items (to iterate through, and paste/replace)
	local targetRegionItems = getRegionItems()
	fdebug("Target: " .. #targetRegionItems)
	doRegionItems(sourceRegionItems, targetRegionItems)
	

	-- select only our initially selected track
	reaper.SetOnlyTrackSelected(selTrack)

	setSelectedItems(sourceRegionItems)

	reaperCMD("_BR_RESTORE_CURSOR_POS_SLOT_1")
	reaperCMD("_SWS_RESTOREVIEW")
	reaperCMD("_SWS_RESTTIME1")
	reaper.PreventUIRefresh(-1)
	reaper.UpdateArrange()

	reaper.Undo_EndBlock(label .. " (" .. #sourceRegionItems .. " to " .. affected .. ")", -1) 

end

if(reaper.CountSelectedMediaItems(0) > 0) then
	main()
end