require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.region'

-- default options: copy this file on Scripts/ActonDev/ and rename it to options where you can freely change the values
-- the file will still exist even after scripts updates, you won't loose your settings
require 'Scripts.ActonDev.deps.options-defaults'
-- this will load YOUR settings and will overwrite defaults
pcall(require, 'Scripts.ActonDev.deps.options')

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
		handleExceededRegionEdges(sourceItem, exceedStart, exceedEnd, keepStartingIn, keepEndingIn)
		-- normal copy items (if we wanna keep exceedign items: gotta call handleExceededRegionEdges before)
		reaperCMD(40698)		
	end
end

-- item, notes are the source item, source notes
function scanPaste(targetRegionItems, sourceItem, sourceNotes)
	fdebug("___SCANPASTE FROM____ " .. sourceNotes)
	fdebug("Target items N:  " .. #targetRegionItems)
	for i=1,#targetRegionItems do
		local tempItem = targetRegionItems[i]

		-- if sourceItems are multiple, some items have been deleted (and pasted over)
		-- so these items have been set to 0
		if tempItem ~= 0 then
			_,chunk =  reaper.GetItemStateChunk(tempItem, "", 0)
			fdebug(i .. " type " .. type(tempItem))
			-- fdebug(chunk)
			local tempNotes = reaper.ULT_GetMediaItemNote(tempItem)
			
			fdebug(i .."#   " .. tempNotes)
			if tempItem == sourceItem then
				-- it's our initial region item, whose region we want to copy
				fdebug("    :::IGNORE:::")
			elseif getRegionName(tempItem) == getRegionName(sourceItem) then
				fdebug("    :::PASTE:::")
				targetRegionItems[i] = 0
				-- paste here
				affected = affected + 1
				-- Unselect all items
				reaperCMD(40289)
				reaper.SetMediaItemSelected(tempItem, 1)
				-- reaper.SetOnlyTrackSelected(selTrack)
				regionItemSelect(tempItem, false)
				-- split items at time selection
				-- reaperCMD(40061)
				-- remove items
				-- reaperCMD(40006)

				if(keepStartingIn==false and keepEndingIn==false) then
					-- remove selected area of items
					reaperCMD(40312)
				else
					handleExceededRegionEdges(sourceItem, exceedStart, exceedEnd, keepStartingIn, keepEndingIn)
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


function doRegionItems(sourceRegionItems, targetRegionItems)
	fdebug("region items here: " .. #sourceRegionItems)
	local i
	for  i = 1, #sourceRegionItems do
		local sourceItem = sourceRegionItems[i]
		-- selTrack = reaper.GetMediaItemTrack(selItem)
		local sourceNotes = reaper.ULT_GetMediaItemNote(sourceItem)
		-- IMPORTANT: here second argument (unselect), must be true
		regionItemSelect(sourceItem, true)

		-- FIX for http://forum.cockos.com/showpost.php?p=1666833&postcount=5
		-- creates a temp item (with notes envelope_fix: cause the methode was created for envelopes first)
		-- but it seems that if first track contains no item, then *SONG tracks have problem in pasting
		firstTrackFix()

		copyItems(sourceItem)
		scanPaste(targetRegionItems, sourceItem, sourceNotes)
	end
end


function main()
	reaper.Undo_BeginBlock()
	local selItem = reaper.GetSelectedMediaItem(0, 0)
	local selTrack = reaper.GetMediaItemTrack(selItem)
	reaper.SetOnlyTrackSelected(selTrack)

	reaper.PreventUIRefresh(1)
	mediaItemGarbageClean()
	reaperCMD("_SWS_SAVETIME1")
	reaperCMD("_SWS_SAVEVIEW")
	reaperCMD("_BR_SAVE_CURSOR_POS_SLOT_1")
	-- save selected region items
	local sourceRegionItems = getSelectedItems()
	fdebug("Source items N: " .. #sourceRegionItems)
	-- select all items in track
	reaperCMD(40421)
	-- save all region items (to iterate through, and paste/replace)
	local targetRegionItems = getSelectedItems()
	fdebug("Target items N:  " .. #targetRegionItems)
	doRegionItems(sourceRegionItems, targetRegionItems)
	

	-- select only our initially selected track
	reaper.SetOnlyTrackSelected(selTrack)

	setSelectedItems(sourceRegionItems)
	mediaItemGarbageClean()

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