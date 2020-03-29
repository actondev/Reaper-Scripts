package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local Log = require('utils.log')
local Common = require('utils.common')
local RegionItems = require('utils.region_items')
local Store = require('utils.store')

Log.isdebug = true

local regionItem = reaper.GetSelectedMediaItem(0, 0)

Common.undoBeginBlock()
Common.preventUIRefresh(1)
Store.storeTimeSelection()

RegionItems.select(regionItem)

Store.restoreTimeSelection()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Select")
