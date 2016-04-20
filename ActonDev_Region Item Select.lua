package.path = reaper.GetResourcePath().. package.config:sub(1,1) .. '?.lua;' .. package.path
require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.region'

-- default options: copy this file on Scripts/ActonDev/ and rename it to options where you can freely change the values
-- the file will still exist even after scripts updates, you won't loose your settings
require 'Scripts.ActonDev.deps.options-defaults'
-- this will load YOUR settings and will overwrite defaults
pcall(require, 'Scripts.ActonDev.deps.options')

-- This script is a little buggy when items exceed region edges.
-- TODO: fix this :P

quantizeThreshold = RegionSelect.quantizeThreshold
keepStartingIn = RegionSelect.keepStartingIn
keepEndingIn = RegionSelect.keepEndingIn

debug_mode = 0

setOfSelectedItems = {}

function doRegionItems(regionItems, selectiveRegion)
	-- keepStartingIn = false
	-- keepEndingIn = false
	local i
	local flagSplitted = false
	local cleanEnvelopeFixes = (#regionItems == 1)
	for  i = 1, #regionItems do
		-- unselect all items
		reaperCMD(40289)
		fdebug("HERE ASD")
		-- fdebug(regionItems[i])
		regionItemSelect(regionItems[i], cleanEnvelopeFixes, selectiveRegion)
		local exceedStart, exceedEnd, countQuantized = itemsExceedRegionEdges(regionItems[i], quantizeThreshold, true)
		flagSplitted = flagSplitted or exceedStart or exceedEnd
		handleExceededRegionEdges(regionItems[i], exceedStart, exceedEnd, keepStartingIn, keepEndingIn)
		setOfSelectedItems[#setOfSelectedItems + 1] = getRegionItems()
	end
	-- if flagSplitted then
	-- 	reaper.ShowMessageBox("Some items have been splitted.\nThis action works better with single region items selected.", "ActonDev: Region Item Select", 0)
	-- end

	for i = 1,#setOfSelectedItems do
		local tempTable = setOfSelectedItems[i]
		for j=1, #tempTable do
			if tempTable[j] then
				reaper.SetMediaItemSelected(tempTable[j], true)
			end
		end
	end
end


label = "ActonDev: folder select"

function main()
	

	reaperCMD("_SWS_SAVETIME1")
	mediaItemGarbageClean()
	regionItems = getRegionItems()

	if #regionItems == 0 then
		return -1
	end
	sourceTrack = reaper.GetMediaItemTrack(regionItems[1]);
	
	selTracks = getSelectedTracks()
	local selectiveRegion = false
	fdebug(#selTracks)
	if #selTracks > 1 or (#selTracks == 1 and selTracks[1] ~= sourceTrack) then
		selectiveRegion = true
	end
	-- keep selected track
	
	reaper.SetTrackSelected(sourceTrack, true)
	-- keep selected track's name
	-- local retval;
	-- retval, selName = reaper.GetSetMediaTrackInfo_String(selTrack, "P_NAME", "", false);
	-- let the magic happen
	local countSel = reaper.CountSelectedMediaItems(0)

	doRegionItems(regionItems, selectiveRegion)
	

	-- select only our initially selected track
	if not selectiveRegion then
		reaper.SetOnlyTrackSelected(sourceTrack);
	end

	reaperCMD("_SWS_RESTTIME1")
	-- refresh ui, create undo point
	
	return 0
end

-- run

if(reaper.CountSelectedMediaItems(0) > 0) then
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)
	if main() ~= 0 then
		reaper.ShowMessageBox("Please make a selection of Empty - aka region - items.\nTo create a new one, go to 'Insert > Empty item'.\n\nYou can also run the 'ActonDev_Insert Region Item' script.", "No region items selected!", 0)
	end
	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock(label, -1)
end
