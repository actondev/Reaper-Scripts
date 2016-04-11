require 'Scripts.Actondev.deps.template'
require 'Scripts.Actondev.deps.region'

-- default options: copy this file on Scripts/ActonDev/ and rename it to options where you can freely change the values
-- the file will still exist even after scripts updates, you won't loose your settings
require 'Scripts.ActonDev.options-defaults'
-- this will load YOUR settings and will overwrite defaults
pcall(require, 'Scripts.ActonDev.options')

-- This script is a little buggy when items exceed region edges.
-- TODO: fix this :P

quantizeThreshold = RegionSelect.quantizeThreshold
keepStartingIn = RegionSelect.keepStartingIn
keepEndingIn = RegionSelect.keepEndingIn

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
