package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Common = require('aod.reaper.common')
local RegionItems = require('aod.region_items')
local Store = require('aod.reaper.store')
local Log = require('aod.utils.log')
local regionItem = reaper.GetSelectedMediaItem(0, 0)

-- Log.isdebug = true
Common.undoBeginBlock()
Common.preventUIRefresh(1)
Store.storeTimeSelection()

RegionItems.clear(regionItem)

Store.restoreTimeSelection()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region item: clear")
