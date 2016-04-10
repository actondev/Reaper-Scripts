package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path .. "\n")
require 'ActonDev.deps.template'
require 'ActonDev.deps.region'

local scriptPath = debug.getinfo(1,'S').source:match("@(.+)[/\\].+$")
fdebug(scriptPath)

-- -------------------------------------
-- USER OPTIONS: FEEL FREE TO EDIT THOSE
-- -------------------------------------
-- 
-- 
-- Having some tolerance to the start/end of media items
-- 		Some times some glitches happen and items starts/ends just miliseconds off by the start/end
-- 		of the region edges. This thresholds automatically quantizes items, so no unnecessary splts are
-- 		to happen. (could result in almost zero length items).
-- 		Set to zero to skip this feature (note that you get informed if quantizing happend)
quantizeThreshold = 0.1
-- Set to true to avoid the messageBox
-- 		always trim not suggest, you end up deleting items
-- 		always split safe to use


-- alwaysSplit = false

-- set to true if you want to keep items that start inside the region edges
-- 		comment it out to get prompt
-- keepStartingIn = true
-- set to true if you want to keep items that start inside the region edges
-- 		comment it out to get prompt
-- keepEndingIn = true

-- Note: if keepStartingIn is true and keepEnding in is false,
-- 		items that start outside the region area, but ending in will be splitted (no prompt)

-- 
-- --------------------------------------
-- END OF USER OPTIONS
-- --------------------------------------


-- editing below here not SO advised :P

debug_mode = 1

-- setting to 6: responding in YES in the {Split?} dialog
-- setting to 2: responding in NO in the {Split?} dialog
keepStartingIn = boolToDialog(keepStartingIn)
keepEndingIn = boolToDialog(keepEndingIn)


function main()
	reaper.Undo_BeginBlock()
	selItem = reaper.GetSelectedMediaItem(0, 0)
	selTrack = reaper.GetMediaItemTrack(selItem);
	_,selChunk =  reaper.GetItemStateChunk(selItem, "", 0)
	
	-- fdebug("Chunk " .. selChunk)
	-- Source type possible values: MIDI, WAVE, MP3.. so i keep the first 3
	-- if no <Source tag in the chunk, then it's an empty item (region item in my case, also known as notes items)
	itemType = string.match(selChunk, "<SOURCE%s(%P%P%P).*\n")
	fdebug(itemType)
	if itemType == nil then
		-- "folder/region" empty item
		reaper.PreventUIRefresh(1)

		reaperCMD("_SWS_SAVETIME1")
		reaperCMD("_BR_SAVE_CURSOR_POS_SLOT_1")

		
		regionItemSelect(selItem)
		local exceedStart, exceedEnd, countQuantized
		exceedStart, exceedEnd, countQuantized = itemsExceedRegionEdges(selItem, quantizeThreshold, true)

		if countQuantized > 0 then
			reaper.ShowMessageBox(countQuantized .. " item(s) quantized (difference in edges below " .. quantizeThreshold .. " ms)\nIt was probably a glitch in their positioning\nUndo if action not desired, and edit the .lua file for the desired threshold.", "ActonDev: Region item Select", 0)
		end

		if  exceedStart then
			actionSelected = keepStartingIn or reaper.ShowMessageBox("Some of the selected items start before of the region item\nSplit items?", "ActonDev: Region Item", 4)
			if actionSelected == 6 then
				-- yes
				reaper.SetEditCurPos(selPosition, false, false)
				-- split at edit cursor, select right
				reaperCMD(40759)
			end
		end
		if  exceedEnd then
			actionSelected = keepEndingIn or reaper.ShowMessageBox("Some of the selected items end after the region item\nSplit items?", "ActonDev: Region Item", 4)
			if actionSelected == 6 then
				-- yes
				reaper.SetEditCurPos(selPosition+selLength, false, false)
				-- split at edit cursor, select left
				reaperCMD(40758)
			end
		end
		-- select only our initially selected track
		reaper.SetOnlyTrackSelected(selTrack);
		reaperCMD("_SWS_RESTTIME1")
		reaperCMD("_BR_RESTORE_CURSOR_POS_SLOT_1")
		-- refresh ui, create undo point
		label = "ActonDev: Select Folder item"
		reaper.PreventUIRefresh(-1)
		reaper.UpdateArrange()

	elseif itemType == "MID" then
		-- built-in midi editor
		label = "ActonDev: Open Midi item"
		reaperCMD("40153")
	else
		label = "ActonDev: Open Audio item"
		reaperCMD("40009")
	end
	-- fdebug(getExtState("MediaItemGarbageGUID"))
	reaper.Undo_EndBlock(label, -1) 
end

if(reaper.CountSelectedMediaItems(0) > 0) then
	main()
end