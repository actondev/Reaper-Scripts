package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path
local Common = require("aod.reaper.common")
local Store = require("aod.reaper.store")

local RegionItems = require("aod.region_items")
local Log = require("aod.utils.log")
local regionItem = reaper.GetSelectedMediaItem(0, 0)

-- Log.isdebug = true

Common.undoBeginBlock()
Store.storeArrangeView()
Store.storeCursorPosition()
Store.storeTimeSelection()
Common.preventUIRefresh(1)

RegionItems.propagate(regionItem)

Store.restoreTimeSelection()
Common.updateArrange()
Store.restoreArrangeView()
Store.restoreCursorPosition()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Propagate")
