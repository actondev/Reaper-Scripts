package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path)
require 'ActonDev.deps.template'
-- for unselectSpecialTracks
require 'ActonDev.deps.region'

debug_mode = 0

function showAll()
	label = "ActonDev: show all"
	reaperCMD("_SWSTL_SHOWALLTCP")
	reaperCMD("_SWS_SELALLPARENTS")
	reaperCMD("_SWS_COLLAPSE")
	-- unselect all tracks
	reaperCMD("40297")
end

-- TODO remove, not needed
function showSpecial()
	-- show first track if it begins with '*'
	local firstTrack = reaper.GetTrack(0,0)
	local trackName
	_, trackName = reaper.GetSetMediaTrackInfo_String(firstTrack, "P_NAME", "", false);
	fdebug(trackName)
	if string.match(trackName, "[*].*") == trackName then
		-- reaper.SetMediaTrackInfo_Value(MediaTrack tr, string parmname, number newvalue)
		-- B_SHOWINTCP 
		reaper.SetMediaTrackInfo_Value(firstTrack, "B_SHOWINTCP", 1)
	end
end

function folderFocus()
	label = "ActonDev: hide / focus"
	-- GetMediaTrackInfo_Value(MediaTrack* tr, const char* parmname)
	-- I_FOLDERDEPTH : int * : folder depth change (0=normal, 1=track is a folder parent, -1=track is the last in the innermost folder, -2=track is the last in the innermost and next-innermost folders, etc
	-- Lua: MediaTrack reaper.GetSelectedTrack(ReaProject proj, integer seltrackidx)
	-- Lua: MediaTrack reaper.GetSelectedTrack(ReaProject proj, integer seltrackidx)
	selTrack = reaper.GetSelectedTrack(0, 0)
	if reaper.GetMediaTrackInfo_Value(selTrack, "I_FOLDERDEPTH") == 0 then
		-- child of parent folder selected
		reaperCMD("_SWS_SELPARENTS")
	end
	reaperCMD("_SWS_UNCOLLAPSE")
	reaperCMD("_SWS_SELCHILDREN2")
	-- invert selection
	reaperCMD("_SWS_TOGTRACKSEL")
	-- also show special tracks?
	-- unselectSpecialTracks("")
	-- hide
	reaperCMD("_SWSTL_HIDETCP")
end

label = ""

function main()
	local focus = false
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)
	selTrack = reaper.GetSelectedTrack(0, 0)
	if reaper.CountSelectedTracks(0) > 0 then
		focus = true
		folderFocus()
	else
		showAll()
	end
	-- select all tracks
	reaperCMD("40296")
	-- if focusing, then unselect special, so the zoomvit happens on the folder only
	if focus then
		-- unselectSpecialTracks("")
	end
	-- Zoom adjustments
	reaper.PreventUIRefresh(-1)
    -- SWS_VZOOMFIT doesn't work if ui refresh is prevented :/
	reaperCMD("_SWS_VZOOMFIT")
    
	-- unselect all tracks
	reaperCMD("40297")

	

    -- reaper.UpdateArrange()
	-- reaper.PreventUIRefresh(-1)
	-- if selTrack then
	-- 	reaper.SetOnlyTrackSelected(selTrack)
	-- 	-- vertical scroll sel tracks into view
	-- 	-- reaperCMD("40913")
	-- else
	-- 	-- unselect all tracks
	-- 	reaperCMD("40297")
	-- end

	reaper.Undo_EndBlock(label, -1) 

end

main()