package.path = reaper.GetResourcePath().. package.config:sub(1,1) .. '?.lua;' .. package.path
require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.region'

-- default options: copy this file on Scripts/ActonDev/ and rename it to options where you can freely change the values
-- the file will still exist even after scripts updates, you won't loose your settings
require 'Scripts.ActonDev.deps.options-defaults'
-- this will load YOUR settings and will overwrite defaults
pcall(require, 'Scripts.ActonDev.deps.options')

debug_mode = 0


quantizeThreshold = RegionSelect.quantizeThreshold
keepStartingIn = RegionSelect.keepStartingIn
keepEndingIn = RegionSelect.keepEndingIn


function main()
	reaper.Undo_BeginBlock()
	local selItem = reaper.GetSelectedMediaItem(0, 0)
	local selTrack = reaper.GetMediaItemTrack(selItem);
	local _,selChunk =  reaper.GetItemStateChunk(selItem, "", 0)
	
	-- fdebug("Chunk " .. selChunk)
	-- Source type possible values: MIDI, WAVE, MP3.. so i keep the first 3
	-- if no <Source tag in the chunk, then it's an empty item (region item in my case, also known as notes items)
	itemType = string.match(selChunk, "<SOURCE%s(%P%P%P).*\n")
	-- fdebug(itemType)
	if itemType == nil then
		-- "folder/region" empty item
		reaper.PreventUIRefresh(1)

		reaperCMD("_SWS_SAVETIME1")
		reaperCMD("_BR_SAVE_CURSOR_POS_SLOT_1")

		
		local countSelected = regionItemSelect(selItem)
		local exceedStart, exceedEnd, countQuantized = false, false, 0
		-- if keepStartingIn or keepEndingIn or threshold > 0

		exceedStart, exceedEnd, countQuantized = itemsExceedRegionEdges(selItem, quantizeThreshold, true)
		-- fdebug("exceedStart")
		-- fdebug(exceedStart)
		handleExceededRegionEdges(selItem, exceedStart, exceedEnd, keepStartingIn, keepEndingIn)


		-- select only our initially selected track
		reaper.SetOnlyTrackSelected(selTrack);
		-- reaperCMD("_SWS_RESTTIME1")
		-- reaperCMD("_BR_RESTORE_CURSOR_POS_SLOT_1")
		-- refresh ui, create undo point
		
		label = "ActonDev Region select: " .. countSelected
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