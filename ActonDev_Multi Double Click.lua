require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.region'
debug_mode = 0

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
-- 		set to nil or 0 to get prompt
keepStartingIn = nil
-- set to true if you want to keep items that start inside the region edges
-- 		set to nil or 0 to get prompt
keepEndingIn = nil

-- Note: if keepStartingIn is true and keepEnding in is false,
-- 		items that start outside the region area, but ending in will be splitted (no prompt)

-- 
-- --------------------------------------
-- END OF USER OPTIONS
-- --------------------------------------




-- editing below here not SO advised :P
-- setting to 6: responding in YES in the {Split?} dialog
-- setting to 2: responding in NO in the {Split?} dialog

keepStartingIn = boolToDialog(keepStartingIn)
keepEndingIn = boolToDialog(keepEndingIn)


function main()
	reaper.Undo_BeginBlock()
	local selItem = reaper.GetSelectedMediaItem(0, 0)
	local selTrack = reaper.GetMediaItemTrack(selItem);
	local _,selChunk =  reaper.GetItemStateChunk(selItem, "", 0)
	
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

		
		local countSelected, fixesInserted = regionItemSelect(selItem)
		local exceedStart, exceedEnd, countQuantized = false, false, 0
		-- if keepStartingIn or keepEndingIn or threshold > 0

		exceedStart, exceedEnd, countQuantized = itemsExceedRegionEdges(selItem, quantizeThreshold, true)
		fdebug("exceedStart")
		fdebug(exceedStart)
		handleExceededRegionEdges(selItem, exceedStart, exceedEnd, keepStartingIn, keepEndingIn)


		-- select only our initially selected track
		reaper.SetOnlyTrackSelected(selTrack);
		reaperCMD("_SWS_RESTTIME1")
		reaperCMD("_BR_RESTORE_CURSOR_POS_SLOT_1")
		-- refresh ui, create undo point
		
		label = "ActonDev Region select: " .. countSelected
		if fixesInserted > 0 then
			label = label .. "+" .. fixesInserted .. "*"
		end
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