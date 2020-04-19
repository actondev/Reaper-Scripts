package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path
local Log = require("aod.utils.log")
-- Log.LEVEL = Log.DEBUG

local Common = require("aod.reaper.common")
local Store = require("aod.reaper.store")
local RegionItems = require("aod.region_items")
local Item = require("aod.reaper.item")

Common.undoBeginBlock()
Store.storeArrangeView()
Store.storeCursorPosition()
Store.storeItemSelection()
Store.storeTimeSelection()
Common.preventUIRefresh(1)

for _, item in ipairs(Item.selected()) do
    RegionItems.pull(item)
end

Store.restoreTimeSelection()
Common.updateArrange()
Store.restoreArrangeView()
Store.restoreCursorPosition()
Store.restoreItemSelection()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Pull")
