package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local Log = require('aod.utils.log')
local Common = require('aod.reaper.common')
local RegionItems = require('aod.region_items')
local Store = require('aod.reaper.store')

Log.isdebug = true

local regionItem = reaper.GetSelectedMediaItem(0, 0)

Common.undoBeginBlock()
Common.preventUIRefresh(1)
Store.storeTimeSelection()

RegionItems.select(regionItem)

Store.restoreTimeSelection()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Select")
