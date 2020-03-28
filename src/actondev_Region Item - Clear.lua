package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local RegionItems = require('utils.region_items')
local Log = require('utils.log')
local regionItem = reaper.GetSelectedMediaItem(0, 0)

-- Log.isdebug = true
RegionItems.clear(regionItem)