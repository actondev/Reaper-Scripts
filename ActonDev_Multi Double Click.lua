package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path .. "\n")
require 'ActonDev.deps.template'
require 'ActonDev.deps.region'

debug_mode = 1

threshold = 0.01
-- threshold = 0.1

function itemsExceedEdges(itemPosition, itemLength, threshold, update)
	-- returns exceed, updated (depends on threshold)
	-- 		updated return value notes the number of edited items (changed item position/length)
	-- local itemPosition = string.match(selChunk, "POSITION ([0-9%.]+)\n")
	-- local itemLength = string.match(selChunk, "LENGTH ([0-9%.]+)\n")
	-- threshold = threshold or 0
	countUpdated = 0
	local ret = false
	local itemEnd = itemPosition+itemLength
	fdebug("Item\t" ..itemPosition .. "\t" .. itemLength)
	-- fdebug(itemLength)
	local countSel = reaper.CountSelectedMediaItems(0)
	for i=1,countSel do
		local tempItem = reaper.GetSelectedMediaItem(0, i-1)
		local _,tempChunk =  reaper.GetItemStateChunk(tempItem, "", 0)
		local tempPosition = string.match(tempChunk, "POSITION ([0-9%.]+)\n")
		local tempLength = string.match(tempChunk, "LENGTH ([0-9%.]+)\n")
		local tempEnd = tempPosition + tempLength
		fdebug("Temp\t" ..tempPosition .. "\t" .. tempLength)
		if tempPosition<itemPosition or tempEnd>itemEnd then
			-- small glitches: fuck off
			if threshold then
				local flag = false
				if update == true then
					local positionDiff = itemPosition - tempPosition
					if positionDiff < threshold then
						flag = true
						reaper.SetMediaItemPosition(tempItem, itemPosition, false)
						tempPosition = itemPosition
						reaper.SetMediaItemLength(tempItem, tempLength - positionDiff, true)
						tempLength = tempLength - positionDiff
					end
					if tempEnd - itemEnd < threshold then
						flag = true
						reaper.SetMediaItemLength(tempItem, itemEnd-tempPosition, false)
					end
					if flag then
						-- updated, now retcheck
						countUpdated = countUpdated + 1
						tempLength = itemEnd-tempPosition
						tempEnd = tempPosition + tempLength
						if tempPosition<itemPosition or tempEnd>itemEnd then ret = true end
					end
				else
					if itemPosition - tempPosition < threshold and tempEnd - itemEnd < threshold then return true end
				end
				-- !if update

			else
				-- no threshold, immediately return true
				return true, 0
			end
			-- !if threshold
		end
	end
	return ret, updated
end

function main()
	reaper.Undo_BeginBlock()
	selItem = reaper.GetSelectedMediaItem(0, 0)
	selTrack = reaper.GetMediaItemTrack(selItem);
	_,selChunk =  reaper.GetItemStateChunk(selItem, "", 0)
	local selPosition = string.match(selChunk, "POSITION ([0-9%.]+)\n")
	local selLength = string.match(selChunk, "LENGTH ([0-9%.]+)\n")
	
	fdebug("Chunk " .. selChunk)
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
		if itemsExceedEdges(selPosition, selLength, threshold, true) then
			local ret = reaper.ShowMessageBox("Selected items exceed edges of region item\nSplit selected items on region item edges?", "ActonDev: Region Item", 3)
			fdebug(ret)
			-- 6 yes, 7 no, 2 cancel
			if ret == 6 then
				-- split items at time selection
				local ret2 = reaper.ShowMessageBox("Also trim? (removes exceeding areas)\nYes = Trim, No = Just split", "ActonDev: Region Item", 4)
				if ret2 == 6 then
					-- Trim items to selected area
					reaperCMD(40508)
				else
					-- NO, just split
					-- Split items at time selection
					reaperCMD(40061)
				end

			elseif ret == 2 then
				-- unselect all items
				reaperCMD(40289)
			end
		end


		-- select only our initially selected track
		reaper.SetOnlyTrackSelected(selTrack);

		reaperCMD("_SWS_RESTTIME1")
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