package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local Log = require("aod.utils.log")
local Common = require("aod.reaper.common")
local RegionItems = require("aod.region_items")
local Store = require("aod.reaper.store")
local Item = require("aod.reaper.item")

local selected = {}

Common.undoBeginBlock()
Common.preventUIRefresh(1)
Store.storeTimeSelection()

for _, item in ipairs(Item.selected()) do
    RegionItems.select(item)
    for _, currSel in ipairs(Item.selected()) do
        selected[#selected+1] = currSel
    end
end

for _, item in ipairs(selected) do
    Item.setSelected(item, true)
end

Store.restoreTimeSelection()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Select")
