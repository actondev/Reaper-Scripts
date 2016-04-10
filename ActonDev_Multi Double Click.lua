package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path .. "\n")
require 'ActonDev.deps.template'
require 'ActonDev.deps.region'

debug_mode = 1
-- -------------------------------------
-- USER OPTIONS: FEEL FREE TO EDIT THOSE
-- -------------------------------------
-- 
-- 
threshold = 0.1
-- Set to true to avoid the messageBox
-- 		always trim not suggest, you end up deleting items
-- 		always split safe to use
alwaysSplit = false
-- 
-- 
-- END OF USER OPTIONS
-- --------------------------------------

-- editing below here not SO advised :P
if alwaysSplit then	actionPreselect = 6 end

function main()
	reaper.Undo_BeginBlock()
	selItem = reaper.GetSelectedMediaItem(0, 0)
	selTrack = reaper.GetMediaItemTrack(selItem);
	_,selChunk =  reaper.GetItemStateChunk(selItem, "", 0)
	local selPosition = string.match(selChunk, "POSITION ([0-9%.]+)\n")
	local selLength = string.match(selChunk, "LENGTH ([0-9%.]+)\n")
	
	-- fdebug("Chunk " .. selChunk)
	fdebug("Here " ..selPosition .. " " .. selLength)
	-- Source type possible values: MIDI, WAVE, MP3.. so i keep the first 3
	-- if no <Source tag in the chunk, then it's an empty item (region item in my case, also known as notes items)
	itemType = string.match(selChunk, "<SOURCE%s(%P%P%P).*\n")
	fdebug(itemType)
	if itemType == nil then
		-- "folder/region" empty item
		reaper.PreventUIRefresh(1)

		reaperCMD("_SWS_SAVETIME1")

		
		regionItemSelect(selItem)
		local exceed,affected
		
		exceed, affected = itemsExceedRegionEdges(selPosition, selLength, threshold, true)
		-- end
		fdebug("Exceed..")
		fdebug(exceed)
		if  exceed == true then
			actionSelected = actionPreselect or reaper.ShowMessageBox("Some of the selected items exceed edges of region item\nSplit selected items on region item edges?", "ActonDev: Region Item", 3)
			-- if actionPreselect == nil then
			-- end
			fdebug("HERE ")
			-- 6 yes, 7 no, 2 cancel
			-- reaperCMD(40061)
			if actionSelected == 6 then
				-- split items at time selection	
				reaperCMD(40061)
			elseif actionSelected == 2 then
				-- unselect all items
				reaperCMD(40289)
			end
		end


		-- select only our initially selected track
		reaper.SetOnlyTrackSelected(selTrack);

		-- reaperCMD("_SWS_RESTTIME1")
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