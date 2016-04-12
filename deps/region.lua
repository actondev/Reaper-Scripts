function setSelectedItems(items)
	-- unselect all items
	reaperCMD(40289)
	local i
	for i=1,#items do
		reaper.SetMediaItemSelected(items[i], true)
	end
end

function setTimeSelectionToItem(item)
	fdebug("setTimeSelectionToItem")
	-- set time selection to items
	reaperCMD(40290)
	-- local itemPosition = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
	-- local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
	-- reaper.GetSet_LoopTimeRange(true, false, itemPosition, itemPosition+itemLength, false)
end

function selectItemsInTimeSelection()
	-- reapers default  command unselect previously selected items ugh..
	reaperCMD(40718)
	-- reaperCMD("_BR_SEL_ALL_ITEMS_TIME_SEL_MIDI")
	-- reaperCMD("_BR_SEL_ALL_ITEMS_TIME_SEL_AUDIO")
	-- reaperCMD("_BR_SEL_ALL_ITEMS_TIME_SEL_EMPTY")
	-- reaperCMD("_BR_SEL_ALL_ITEMS_TIME_SEL_PIP")
end

function getSelectedItems()
	local retRegionItems = {}
	local countItems = reaper.CountSelectedMediaItems(0)
	-- fdebug("countItems: " .. countItems)
	local i
	for i = 1, countItems do
		-- fdebug("i " .. i)
		local tempItem = reaper.GetSelectedMediaItem(0, i-1)
		local state = reaper.ULT_GetMediaItemNote(tempItem)
		-- fdebug("state len " .. string.len(state))
		-- fdebug(state)
		retRegionItems[i] = tempItem
	end
	return retRegionItems
end

function unselectSpecialTracks(ignoreTrackName)
	fdebug("ignore: " .. ignoreTrackName)
	local flagSpecial = false;
	local countSel = reaper.CountSelectedTracks(0)
	local i = countSel - 1
	while true do
		local tempTrack = reaper.GetSelectedTrack(0,i)
		local retval; local trackName;
		retval, trackName = reaper.GetSetMediaTrackInfo_String(tempTrack, "P_NAME", "", false);
		if string.match(trackName, "[*,-].*") == trackName and trackName ~= ignoreTrackName then
			flagSpecial = true
			fdebug("unselect special " .. trackName)
			reaper.SetTrackSelected(tempTrack, 0)
		end
		i = i - 1
		if i < 0 then
			break;
		end
	end
	if flagSpecial then
		reaperCMD("_SWS_TOGTRACKSEL") -- invert track selection
		reaperCMD("_SWS_SELCHILDREN2") -- select children of selected folder tracks
		reaperCMD("_SWS_TOGTRACKSEL") -- invert track selection
	end
end

function region_selectAll(item, trackName)
	-- eg: "*SONG" titled track
	-- will select all tracks
	-- reaperCMD(40290) -- set time selection to items
	fdebug("region select all")
	setTimeSelectionToItem(item)
	reaperCMD(40296) -- select all tracks
	unselectSpecialTracks(trackName)

	
	reaperCMD(40718) -- select all items on selected tracks in current time selection
	-- TODO: split/crop or nothing? little buggy
	-- reaperCMD(40061) -- split items at time selection
	-- reaperCMD(40508) -- trim items to selected area
end

function region_folder(item)
	reaperCMD("_SWS_SELCHILDREN2");
	-- normal mode, will select children
	-- set time selection to items
	-- reaperCMD(40290)
	setTimeSelectionToItem(item)
	-- select all items on selected tracks in current time selection
	-- reaperCMD(40718)
	selectItemsInTimeSelection()
end

function region_ofParentFolder()
	reaperCMD("_SWS_SELPARENTS")
	reaperCMD("_SWS_SELCHILDREN");
	-- normal mode, will select children
	-- set time selection to items
	reaperCMD(40290)
	-- select all items on selected tracks in current time selection
	reaperCMD(40718)
end

function region_followingTracks(selTrack, numToSelect)
	-- set time selection to items
	reaper.SetOnlyTrackSelected(selTrack)
	fdebug("region following tracks " .. numToSelect)
	reaperCMD(40290)
	for i=1,numToSelect do
		-- go to next track (leavin others selected)
		reaperCMD(40287)
	end
	-- select all items on selected tracks in current time selection
	reaperCMD(40718)
end

function mediaItemGarbageClean()
	local garbage = getExtState("MediaItemGarbageGUID")
	fdebug(garbage)
	for token in string.gmatch(garbage, "[{%w%-}]+") do
		fdebug(token)
		local item = reaper.BR_GetMediaItemByGUID(0, token)
		-- fdebug(item)
		if item then
			-- MediaTrack reaper.GetMediaItem_Track(MediaItem item)
			local track = reaper.GetMediaItem_Track(item)
			reaper.DeleteTrackMediaItem(track, item)
		end
	end
	setExtState("MediaItemGarbageGUID", "")
	reaper.UpdateArrange()
end

function mediaItemGarbageCleanSelected()
	fdebug("mediaItemGarbageCleanSelected")
	local countSel = reaper.CountSelectedMediaItems(0)
	local i
	for i=1,countSel do
		local item = reaper.GetSelectedMediaItem(0, countSel-i)
		local notes = reaper.ULT_GetMediaItemNote(item)
		fdebug(notes)
		if notes == "envelope_fix" then
			-- remove it!
			local track = reaper.GetMediaItem_Track(item)
			reaper.DeleteTrackMediaItem(track, item)
		end
	end
end

function firstTrackFix()
	local tempTrack = reaper.GetSelectedTrack(0,0)
	local tempItem = reaper.AddMediaItemToTrack(tempTrack)
	local startOut, endOut = reaper.GetSet_LoopTimeRange(false, false, 0, 0, 0)
	reaper.SetMediaItemInfo_Value(tempItem, "D_POSITION", startOut)
	reaper.SetMediaItemInfo_Value(tempItem, "D_LENGTH", endOut - startOut)
	reaper.ULT_SetMediaItemNote(tempItem, "envelope_fix")
	reaper.SetMediaItemSelected(tempItem, true)
	local guid = reaper.BR_GetMediaItemGUID(tempItem)
	appendExtState("MediaItemGarbageGUID", guid)
end

-- insert an empty item wherever there is an envelope (so that envelope gets copied correctly)
function envelopeFix(item)
	local selTrack = reaper.GetMediaItemTrack(item)
	local countItemsInserted = 0
	-- reaper.GetSelectedTrack(ReaProject proj, integer seltrackidx)
	-- reaper.CountSelectedTracks(ReaProject proj)
	local countSelTracks = reaper.CountSelectedTracks(0)
	local i
	for i=1,countSelTracks do
		local tempTrack = reaper.GetSelectedTrack(0, i-1)
		if tempTrack ~= selTrack and reaper.CountTrackEnvelopes(tempTrack) > 0 then
			countItemsInserted = countItemsInserted +1
			fdebug("here")
			local tempItem = reaper.AddMediaItemToTrack(tempTrack)
			_,chunk =  reaper.GetItemStateChunk(tempItem, "", 0)
			fdebug(i .. " type " .. type(tempItem))
			fdebug(chunk)
			-- number startOut retval, number endOut reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number startOut, number endOut, boolean allowautoseek)
			local startOut, endOut = reaper.GetSet_LoopTimeRange(false, false, 0, 0, 0)
			reaper.SetMediaItemInfo_Value(tempItem, "D_POSITION", startOut)
			reaper.SetMediaItemInfo_Value(tempItem, "D_LENGTH", endOut - startOut)
			reaper.ULT_SetMediaItemNote(tempItem, "envelope_fix")
			reaper.SetMediaItemSelected(tempItem, true)
			local guid = reaper.BR_GetMediaItemGUID(tempItem)
			appendExtState("MediaItemGarbageGUID", guid)
			-- local prevGarbage
			-- _,prevGarbage = reaper.GetProjExtState(0, "ActonDev", "MediaItemGarbageGUID", string value)
			-- local newGarbage = prevGarbage .. newGarbage .. ";" 
			-- reaper.SetProjExtState(0, "ActonDev", "MediaItemGarbageGUID", newGarbage)
		end
	end
	return countItemsInserted
end

-- region items are the empty items with notes (NOT midi notes! :P) in them
function regionItemSelect(item, clean)
	if clean then
		-- do not delete items when selection multiple regions (cause temporarily selected items get stores, then unselected and next region items get selected..)
		-- final stage: select all items. If some have gotten deleted results in error: plus no envelope_fix
		mediaItemGarbageClean()
	end

	-- unselect needed when copying regions
	-- NOT needed, when we want to select multiple (sequential) regions
	-- unselect all items
	reaperCMD(40289)
	reaper.SetMediaItemSelected(item, true)
	local selTrack = reaper.GetMediaItemTrack(item)
	reaper.SetOnlyTrackSelected(selTrack)
	-- set first selected track as last touched track
	reaperCMD(40914)

	local retval; local trackName;
	retval, trackName = reaper.GetSetMediaTrackInfo_String(selTrack, "P_NAME", "", false);
	-- fdebug("trackname " .. trackName)
	
	local firstChar = string.sub(trackName, 1,1)
	-- old way, unnecessary: if string.match(trackName, "[*].*") == trackName then
	if firstChar == "*" then
		-- select across all tracks
		region_selectAll(item, trackName)
		-- % is escape character (^ is special)
	elseif firstChar == "^" then
		-- select the children of this tracks parent
		region_ofParentFolder()
	elseif firstChar == ">" then
		-- select folling n tracks (siblings)
		local numToSelect = string.match(trackName, ">(%d+).*")
		if numToSelect == nil then
			numToSelect = 1
		end
		region_followingTracks(selTrack, numToSelect)
	else
		-- normal behavior: item is on a folder, selecting items of children tracks
		region_folder(item)
	end
	-- set first selected track as last touched track
	reaperCMD(40914)
	mediaItemGarbageCleanSelected()
	local countItemsSelected = reaper.CountSelectedMediaItems(0) - 1
	local fixesInserted = envelopeFix(item)
	return countItemsSelected, fixesInserted
end

function handleExceededRegionEdges(sourceItem, exceedStart, exceedEnd, keepStartingIn, keepEndingIn)
	local itemPosition = reaper.GetMediaItemInfo_Value(sourceItem, "D_POSITION")
	local itemLength = reaper.GetMediaItemInfo_Value(sourceItem, "D_LENGTH")
	local itemNotes = reaper.ULT_GetMediaItemNote(sourceItem)

	if exceedStart then
		local actionSelected = boolToDialog(keepEndingIn) or reaper.ShowMessageBox("Some of the selected items start before of the region item\nSplit items?", "Region: \""..itemNotes.."\"", 4)
		if actionSelected == 6 then
			-- split? yes
			keepEndingIn = false
			reaper.SetEditCurPos(itemPosition, false, false)
			-- split at edit cursor, select right
			reaperCMD(40759)
		end
	end
	if exceedEnd then
		local actionSelected = boolToDialog(keepStartingIn) or reaper.ShowMessageBox("Some of the selected items end after the region item\nSplit items?", "Region: \""..itemNotes.."\"", 4)
		if actionSelected == 6 then
			-- split? yes
			keepStartingIn = false
			reaper.SetEditCurPos(itemPosition+itemLength, false, false)
			-- split at edit cursor, select left
			reaperCMD(40758)
		end
	end
end

function activeTakeName(item)
	local take = reaper.GetActiveTake(item)
	-- fdebug(take)
	if take == nil then
		return reaper.ULT_GetMediaItemNote(item)
	else
		return reaper.GetTakeName(take)
	end
end

function itemsExceedRegionEdges(regionItem, threshold)
	-- debug_mode = debug_mode-1
	-- returns exceedStart, exceedEnd, countUpdated (depends on threshold)
	-- 	 	countUpdated return value notes the number of edited items (changed item position/length)

	-- return values
	fdebug("itemsExceedRegionEdges " .. reaper.ULT_GetMediaItemNote(regionItem) )
	local exceedStart, exceedEnd, countQuantized = false, false, 0

	-- local _,chunk =  reaper.GetItemStateChunk(regionItem, "", 0)
	local regionPosition = reaper.GetMediaItemInfo_Value(regionItem, "D_POSITION")
	local regionLength = reaper.GetMediaItemInfo_Value(regionItem, "D_LENGTH")
	local regionEnd = regionPosition+regionLength
	local regionNotes = reaper.ULT_GetMediaItemNote(regionItem)
	
	fdebug("\tItem\t" ..regionPosition .. "\t" .. regionEnd)
	-- fdebug(regionLength)
	local countSel = reaper.CountSelectedMediaItems(0)
	for i=1,countSel do
		local tempItem = reaper.GetSelectedMediaItem(0, i-1)
		local tempPosition = reaper.GetMediaItemInfo_Value(tempItem, "D_POSITION")
		local tempLength = reaper.GetMediaItemInfo_Value(tempItem, "D_LENGTH")
		local tempEnd = tempPosition + tempLength
		local diffStart = regionPosition - tempPosition
		local diffEnd = tempEnd - regionEnd
		-- when selelcting multiple region regions, ignore those that are off limits
		-- also check tempItem ~= regionItem ?
		fdebug("\tTemp\t" ..tempPosition .. "\t" .. tempEnd .. "\t" .. activeTakeName(tempItem))
		if  tempItem ~= regionItem and (tempEnd>regionPosition and tempPosition<regionEnd) then 
			fdebug("\tIn here")

			local flagUpdated = false
			
			-- checking region starts
			if diffStart > 0 then
				fdebug("\ttempPosition<regionPosition, true")
				-- small glitches: fuck off
				if threshold > 0 then
					fdebug("\there 1")
					if  diffStart < threshold then
						-- fdebug("position diffStart " .. )
						flagUpdated = true
						reaper.SetMediaItemPosition(tempItem, regionPosition, false)
						tempPosition = regionPosition
						-- keep same region end (since position -start- changed)
						reaper.SetMediaItemLength(tempItem, tempLength - diffStart, true)
						tempLength = tempLength - diffStart
						tempEnd = tempPosition + tempLength
					else
						exceedStart = true
					end
				else
					-- threshold == 0
					exceedStart = true
				end
			end
			-- !exceedStart

			-- checking region ends (updating diffEnd cause it might changed with quantizing)
			diffEnd = tempEnd - regionEnd
			if diffEnd > 0 then
				fdebug("\ttempEnd>regionEnd, true")
				if threshold > 0 then
					if  diffEnd<threshold then
						flagUpdated = true
						reaper.SetMediaItemLength(tempItem, regionEnd-tempPosition, false)
						tempLength = regionEnd-tempPosition
						tempEnd = tempPosition + tempLength
					else
						exceedEnd = true
					end
				else
					-- threshold == 0
					exceedEnd = true
				end
			end

			if flagUpdated then
				countQuantized = countQuantized + 1
			end
		end
		-- end if same region as source
		fdebug("")
	end
	-- !end for

	if countQuantized > 0 then
		reaper.ShowMessageBox(countQuantized .. " item(s) quantized in \"" .. regionNotes .. "\" region.\nDifference in edges was below " .. quantizeThreshold .. " ms (was probably a glitch in their positioning)\n\nUndo if action not desired, and create/edit the options.lua file for the desired threshold.", "Region: \"".. regionNotes .. "\"", 0)
	end

	-- debug_mode = debug_mode+1
	return exceedStart, exceedEnd, countQuantized
end