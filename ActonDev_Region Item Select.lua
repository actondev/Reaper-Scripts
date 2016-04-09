package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path)
require 'ActonDev.deps.template'
require 'ActonDev.deps.region'

debug_mode = 0

function doRegionItems(regionItems)
	local i
	for  i = 1, reaper.CountSelectedMediaItems(0) do
		regionItemSelect(regionItems[i], false)
	end
end


label = "ActonDev: folder select"

function main()
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	reaperCMD("_SWS_SAVETIME1")

	regionItems = getRegionItems()
	-- keep selected track
	selTrack = reaper.GetMediaItemTrack(regionItems[1]);
	-- keep selected track's name
	-- local retval;
	-- retval, selName = reaper.GetSetMediaTrackInfo_String(selTrack, "P_NAME", "", false);
	-- let the magic happen
	doRegionItems(regionItems)

	-- select only our initially selected track
	reaper.SetOnlyTrackSelected(selTrack);

	reaperCMD("_SWS_RESTTIME1")
	-- refresh ui, create undo point
	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock(label, -1) 
end

-- run

if(reaper.CountSelectedMediaItems(0) > 0) then
	main()
end
