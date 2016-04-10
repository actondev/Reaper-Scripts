function setSelectedItems(items)
	-- unselect all items
	reaperCMD(40289)
	local i
	for i=1,#items do
		reaper.SetMediaItemSelected(items[i], true)
	end
end

function getRegionItems()
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

function region_selectAll(trackName)
	-- eg: "*SONG" titled track
	-- will select all tracks
	reaperCMD(40290) -- set time selection to items
	reaperCMD(40296) -- select all tracks
	unselectSpecialTracks(trackName)

	
	reaperCMD(40718) -- select all items on selected tracks in current time selection
	-- TODO: split/crop or nothing? little buggy
	-- reaperCMD(40061) -- split items at time selection
	-- reaperCMD(40508) -- trim items to selected area
end

function region_folder()
	reaperCMD("_SWS_SELCHILDREN2");
	-- normal mode, will select children
	-- set time selection to items
	reaperCMD(40290)
	-- select all items on selected tracks in current time selection
	reaperCMD(40718)
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
		fdebug(item)
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
	local countSel = reaper.CountSelectedMediaItems(0)
	local i
	for i=1,countSel do
		local item = reaper.GetSelectedMediaItem(0, countSel-i)
		local notes = reaper.ULT_GetMediaItemNote(item)
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

	-- reaper.GetSelectedTrack(ReaProject proj, integer seltrackidx)
	-- reaper.CountSelectedTracks(ReaProject proj)
	local countSelTracks = reaper.CountSelectedTracks(0)
	local i
	for i=1,countSelTracks do
		local tempTrack = reaper.GetSelectedTrack(0, i-1)
		if tempTrack ~= selTrack and reaper.CountTrackEnvelopes(tempTrack) > 0 then
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
end

-- region items are the empty items with notes (NOT midi notes! :P) in them
function regionItemSelect(item, unselect)
	mediaItemGarbageClean()

	-- unselect needed when copying regions
	-- NOT needed, when we want to select multiple (sequential) regions
	if unselect then
		-- unselect all items
		reaperCMD(40289)
	end
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
		region_selectAll(trackName)
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
		region_folder()
	end
	-- set first selected track as last touched track
	reaperCMD(40914)
	mediaItemGarbageCleanSelected()
	envelopeFix(item)
end