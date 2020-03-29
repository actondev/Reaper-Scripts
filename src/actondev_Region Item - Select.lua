package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local Log = require('utils.log')
local Common = require('utils.common')
local RegionItems = require('utils.region_items')

Log.isdebug = true

local regionItem = reaper.GetSelectedMediaItem(0, 0)

Common.undoBeginBlock()
Common.preventUIRefresh(1)

RegionItems.select(regionItem)

Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Select")
