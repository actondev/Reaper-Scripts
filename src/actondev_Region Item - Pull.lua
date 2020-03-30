package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
local Common = require('utils.common')
local Store = require('utils.store')
local RegionItems = require('utils.region_items')
local Log = require('utils.log')

-- Log.isdebug = true

local regionItem = reaper.GetSelectedMediaItem(0, 0)

Common.undoBeginBlock()
Store.storeArrangeView()
Store.storeCursorPosition()
Store.storeTimeSelection()
Common.preventUIRefresh(1)

RegionItems.pull(regionItem)

Store.restoreTimeSelection()
Common.updateArrange()
Store.restoreArrangeView()
Store.restoreCursorPosition()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Pull")
