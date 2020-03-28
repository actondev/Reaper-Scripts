package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
require 'deps.template'

debug_mode = 0

label = "ActonDev: Insert Region Item"

reaper.Undo_BeginBlock()

-- insert empty item
reaperCMD("40142")
item = reaper.GetSelectedMediaItem(0, 0)
_,chunk =  reaper.GetItemStateChunk(item, "", 0)

local retval,name  = reaper.GetUserInputs("Insert Item Title", 1, "Region Item Title", "")
if not retval then
	name = "Unnamed"
end

chunk = string.gsub(chunk, ">", "<NOTES\n|"..name.."\n>\nIMGRESOURCEFLAGS 2\n>")
reaper.SetItemStateChunk(item, chunk, 0)

reaper.Undo_EndBlock(label, -1) 