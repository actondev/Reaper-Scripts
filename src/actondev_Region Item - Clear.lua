package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Common = require('utils.common')
local RegionItems = require('utils.region_items')
local Store = require('utils.store')
local Log = require('utils.log')
local regionItem = reaper.GetSelectedMediaItem(0, 0)

-- Log.isdebug = true
Common.undoBeginBlock()
Common.preventUIRefresh(1)
Store.storeTimeSelection()

RegionItems.clear(regionItem)

Store.restoreTimeSelection()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region item: clear")
