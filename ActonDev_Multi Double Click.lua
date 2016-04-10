package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path .. "\n")
require 'ActonDev.deps.template'
require 'ActonDev.deps.region'

debug_mode = 1

threshold = 0.01
-- threshold = 0.1

-- Set to true to avoid the messageBox
-- 		always trim not suggest, you end up deleting items
-- 		always split safe to use
alwaysSplit = false
if alwaysSplit then	actionPreselect = 6 end


function itemsExceedEdges(itemPosition, itemLength, threshold, update)
	-- returns exceed, updated (depends on threshold)
	-- 	 updated return value notes the number of edited items (changed item position/length)
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
			fdebug("check 1, true")
			-- small glitches: fuck off
			if threshold > 0 then
				fdebug("here 1")
				local flagUpdated = false
				if update == true then
					local positionDiff = itemPosition - tempPosition
					if (positionDiff >0 and positionDiff < threshold) then
						-- fdebug("position diff " .. )
						flagUpdated = true
						reaper.SetMediaItemPosition(tempItem, itemPosition, false)
						tempPosition = itemPosition
						reaper.SetMediaItemLength(tempItem, tempLength - positionDiff, true)
						tempLength = tempLength - positionDiff
					end

					local endDiff = tempEnd - itemEnd

					if (endDiff>0 and endDiff<threshold) then
						flagUpdated = true
						reaper.SetMediaItemLength(tempItem, itemEnd-tempPosition, false)
						tempLength = itemEnd-tempPosition
						tempEnd = tempPosition + tempLength
					end
					if flagUpdated then
						countUpdated = countUpdated + 1
						-- items updated, recheck
						if tempPosition<itemPosition or tempEnd>itemEnd then
							ret = true
						end
					else
						-- items not updated, so difference greater than threshold
						ret = true
					end
				end
			else
				-- threshold is 0, so yeah: they exceed
				return true,0
			end
		end 
		-- !item not exceeding
	end
	-- end of for
	return ret, updated
end

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
		
		exceed, affected = itemsExceedEdges(selPosition, selLength, threshold, true)
		-- end
		fdebug("Exceed..")
		fdebug(exceed)
		if  exceed == true then
			actionSelected = actionPreselect or reaper.ShowMessageBox("Selected items exceed edges of region item\nSplit selected items on region item edges?", "ActonDev: Region Item", 3)
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