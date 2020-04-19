package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path
local Log = require("aod.utils.log")
Log.LEVEL = Log.WARN

local Common = require("aod.reaper.common")
local Store = require("aod.reaper.store")

local RegionItems = require("aod.region_items")
local regionItem = reaper.GetSelectedMediaItem(0, 0)

Common.undoBeginBlock()
Store.storeArrangeView()
Store.storeCursorPosition()
Store.storeTimeSelection()
Common.preventUIRefresh(1)

RegionItems.propagate(regionItem)

Store.restoreTimeSelection()
Store.restoreCursorPosition()
Common.updateArrange()
Store.restoreArrangeView()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Propagate")
