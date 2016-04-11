require 'Scripts.Actondev.deps.template'
-- required for unselectSpecialTracks
require 'Scripts.Actondev.deps.region'

debug_mode = 1

label = "ActonDev: Folder Track Toggle Focus"

function showAll()
	fdebug("Show all 1")
	if( getExtState("FolderFocus") ~= "true") then
		return
	end
	fdebug("Show all 2")
	label = "ActonDev: Show all"
	reaperCMD("_SWSTL_SHOWALLTCP")
	reaperCMD("_SWS_SELALLPARENTS")
	reaperCMD("_SWS_COLLAPSE")
	-- unselect all tracks
	reaperCMD("40297")
	restoreHiddenTracks()
	setExtState("FolderFocus", "false")
	zoomFit()
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

function saveHiddenTracks()
	fdebug("Save hidden tracks")
	-- select all tracks
	reaperCMD("40296")
	-- reaperCMD("_SWS_SELCHILDREN2")
	-- invert selection
	setExtState("HiddenTCP", "")
	reaperCMD("_SWS_TOGTRACKSEL")
	local selTracks = reaper.CountSelectedTracks(0)
	for i=1,selTracks do
		local tempTrack = reaper.GetSelectedTrack(0, i-1)
		local vis = reaper.GetMediaTrackInfo_Value(tempTrack, "B_SHOWINTCP")
		local _,name = reaper.GetSetMediaTrackInfo_String(tempTrack, "P_NAME", "", false)
		local guid = reaper.GetTrackGUID(tempTrack)
		fdebug(name .. " hidden: " .. vis .. guid)
		appendExtState("HiddenTCP", guid)
	end
end

function restoreHiddenTracks()
	local hidden = getExtState("HiddenTCP")
	for token in string.gmatch(hidden, "[{%w%-}]+") do
		fdebug(token)
		local track = reaper.BR_GetMediaTrackByGUID(0, token)
		-- fdebug(item)
		if track then
			reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 0)
		end
	end
	setExtState("HiddenTCP", "")
end

function folderFocus()
	label = "ActonDev: Folder focus"
	fdebug("Folder focus")
	setExtState("FolderFocus", "true")
	local selTrack = reaper.GetSelectedTrack(0, 0)
	saveHiddenTracks()
	reaper.SetOnlyTrackSelected(selTrack)
	-- label = "ActonDev: hide / focus"
	-- GetMediaTrackInfo_Value(MediaTrack* tr, const char* parmname)
	-- I_FOLDERDEPTH : int * : folder depth change (0=normal, 1=track is a folder parent, -1=track is the last in the innermost folder, -2=track is the last in the innermost and next-innermost folders, etc
	-- Lua: MediaTrack reaper.GetSelectedTrack(ReaProject proj, integer seltrackidx)
	-- Lua: MediaTrack reaper.GetSelectedTrack(ReaProject proj, integer seltrackidx)
	
	local folderDepth = reaper.GetMediaTrackInfo_Value(selTrack, "I_FOLDERDEPTH")
	local trackDepth = reaper.GetTrackDepth(selTrack)


	
	if folderDepth == 0 then
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
	zoomFit()
end


function zoomFit()
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
	reaper.PreventUIRefresh(1)
end

function main()

	local focus = false
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)
	local selTrack = reaper.GetSelectedTrack(0, 0)
	
	-- saveHiddenTracks()
	
	if selTrack and getExtState("FolderFocus")~= "true" then
		local folderDepth = reaper.GetMediaTrackInfo_Value(selTrack, "I_FOLDERDEPTH")
		local trackDepth = reaper.GetTrackDepth(selTrack)

		fdebug("Folder depth " .. folderDepth)
		fdebug("trackDepth " .. trackDepth)

		if (folderDepth == 1 or trackDepth > 0) then
			-- focus = true
			folderFocus()
			reaper.SetOnlyTrackSelected(selTrack)
		else
			showAll()
		end
	else
		showAll()
	end
	
	-- reaper.UpdateArrange()
	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock(label, -1) 

end

main()