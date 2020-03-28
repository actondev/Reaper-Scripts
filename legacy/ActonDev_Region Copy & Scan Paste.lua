package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'deps.template'
require 'deps.region'

-- default options: copy this file on Scripts/ActonDev/ and rename it to options where you can freely change the values
-- the file will still exist even after scripts updates, you won't loose your settings
require 'deps.options-defaults'
-- this will load YOUR settings and will overwrite defaults
pcall(require, 'deps.options')

debug_mode = 0


quantizeThreshold = RegionCopyScanPaste.quantizeThreshold
keepStartingIn = RegionCopyScanPaste.keepStartingIn
keepEndingIn = RegionCopyScanPaste.keepEndingIn

label = 'ActonDev: Copy Region'

function copyItems(sourceItem)
	-- split items at time selection
	-- reaperCMD(40061)
	-- copy items
	-- fdebug(sourceItem)
	-- fdebug(" HERE " .. reaper.ULT_GetMediaItemNote(sourceItem) )
	local exceedStart, exceedEnd, countQuantized = itemsExceedRegionEdges(sourceItem, quantizeThreshold, true)
	-- gfx.init(200,300)
	fdebug("exceedStart..")
	fdebug(exceedStart)

	if (keepStartingIn==false or not exceedEnd) and keepEndingIn==false then
		-- copy selected are of items
		reaperCMD(40060)
	else
		keepStartingIn, keepEndingIn = handleExceededRegionEdges(sourceItem, exceedStart, exceedEnd, keepStartingIn, keepEndingIn)
		-- normal copy items (if we wanna keep exceedign items: gotta call handleExceededRegionEdges before)
		reaperCMD(40698)		
	end
end

-- item, notes are the source item, source notes
function scanPaste(targetRegionItems, sourceItem, sourceNotes, selectiveRegion)
	fdebug("___SCANPASTE FROM____ " .. sourceNotes)
	fdebug("Target items N:  " .. #targetRegionItems)
	for i=1,#targetRegionItems do
		local targetItem = targetRegionItems[i]

		-- if sourceItems are multiple, some items have been deleted (and pasted over)
		-- so these items have been set to 0
		if targetItem ~= 0 then
			_,chunk =  reaper.GetItemStateChunk(targetItem, "", 0)
			fdebug(i .. " type " .. type(targetItem))
			-- fdebug(chunk)
			local tempNotes = reaper.ULT_GetMediaItemNote(targetItem)
			
			fdebug(i .."#   " .. tempNotes)
			if targetItem == sourceItem then
				-- it's our initial region item, whose region we want to copy
				fdebug("    :::IGNORE:::")
			elseif getRegionName(targetItem) == getRegionName(sourceItem) then
				fdebug("    :::PASTE:::")
				targetRegionItems[i] = 0
				-- paste here
				affected = affected + 1
				-- Unselect all items
				reaperCMD(40289)
				reaper.SetMediaItemSelected(targetItem, 1)
				-- reaper.SetOnlyTrackSelected(selTrack)
				regionItemSelect(targetItem, false, selectiveRegion)
				-- split items at time selection
				-- reaperCMD(40061)
				-- remove items
				-- reaperCMD(40006)

				local exceedStart, exceedEnd, countQuantized = itemsExceedRegionEdges(targetItem, quantizeThreshold, true)

				if (keepStartingIn==false and keepEndingIn==false) then
					-- remove selected area of items
					reaperCMD(40312)
				else
					keepStartingIn, keepEndingIn = handleExceededRegionEdges(targetItem, exceedStart, exceedEnd, keepStartingIn, keepEndingIn)
					-- remove items
					reaperCMD(40006)
				end
				-- paste
				reaperCMD(40058)
				
			end
		end
		mediaItemGarbageCleanSelected()
	end
	mediaItemGarbageCleanSelected()
end

affected = 0


function doRegionItems(sourceRegionItems, targetRegionItems, selectiveRegion)
	fdebug("region items here: " .. #sourceRegionItems)
	local i
	for  i = 1, #sourceRegionItems do
		local sourceItem = sourceRegionItems[i]
		-- selTrack = reaper.GetMediaItemTrack(selItem)
		local sourceNotes = reaper.ULT_GetMediaItemNote(sourceItem)
		-- IMPORTANT: here second argument (unselect), must be true
		regionItemSelect(sourceItem, true, selectiveRegion)

		-- FIX for http://forum.cockos.com/showpost.php?p=1666833&postcount=5
		-- creates a temp item (with notes envelope_fix: cause the methode was created for envelopes first)
		-- but it seems that if first track contains no item, then *SONG tracks have problem in pasting
		firstTrackFix()

		copyItems(sourceItem)
		scanPaste(targetRegionItems, sourceItem, sourceNotes, selectiveRegion)
	end
end


function main()
	local selItem = reaper.GetSelectedMediaItem(0, 0)
	local selTrack = reaper.GetMediaItemTrack(selItem)
	-- set first selected track as last touched track
	reaperCMD(40914)

	reaperCMD("_SWS_SAVETIME1")
	reaperCMD("_SWS_SAVEVIEW")
	reaperCMD("_BR_SAVE_CURSOR_POS_SLOT_1")


	mediaItemGarbageClean()

	local sourceRegionItems = getRegionItems()
	fdebug(#sourceRegionItems)
	if #sourceRegionItems == 0 then
		return -1
	end
	sourceTrack = reaper.GetMediaItemTrack(sourceRegionItems[1]);
	fdebug("Source items N: " .. #sourceRegionItems)

	selTracks = getSelectedTracks()
	local selectiveRegion = false
	fdebug(#selTracks)
	if #selTracks > 1 or (#selTracks == 1 and selTracks[1] ~= sourceTrack) then
		selectiveRegion = true
	end
	reaper.SetTrackSelected(sourceTrack, true)

	
	-- save selected region items

	-- select all items in track
	reaperCMD(40421)
	-- save all region items (to iterate through, and paste/replace)
	local targetRegionItems = getRegionItems()
	fdebug("Target items N:  " .. #targetRegionItems)
	
	doRegionItems(sourceRegionItems, targetRegionItems, selectiveRegion)
	

	-- select only our initially selected track
	if not selectiveRegion then
		reaper.SetOnlyTrackSelected(selTrack)
	end

	setSelectedItems(sourceRegionItems)
	mediaItemGarbageClean()

	reaperCMD("_BR_RESTORE_CURSOR_POS_SLOT_1")
	reaperCMD("_SWS_RESTOREVIEW")
	reaperCMD("_SWS_RESTTIME1")

	reaper.UpdateArrange()
	return 0
end

if(reaper.CountSelectedMediaItems(0) > 0) then
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)
	if main() ~= 0 then
		reaper.ShowMessageBox("Please make a selection of Empty - aka region - items.\nTo create a new one, go to 'Insert > Empty item'.\n\nYou can also run the 'ActonDev_Insert Region Item' script.", "No region items selected!", 0)
	end
	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock(label, -1)
end