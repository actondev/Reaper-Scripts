package.path = debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" .. package.path

local RegionItems = require("aod.region_items")
local Log = require("aod.utils.log")
local Item = require("aod.reaper.item")
local Common = require("aod.reaper.common")
local Store = require("aod.reaper.store")
local Parse = require("aod.utils.parse")
local ItemManipulation = require("aod.item_manipulation")

Common.undoBeginBlock()
Common.preventUIRefresh(1)

Store.storeCursorPosition()
Store.storeTimeSelection()
Store.storeItemSelection()

for _, item in pairs(Item.selected()) do
    RegionItems.select(item)
    local notes = Item.notes(item)

    local manipulationOpts = Parse.parsedTaggedJson(notes, ItemManipulation.TAG_V1)

    ItemManipulation.manipulateSelected(manipulationOpts)
end

Store.restoreCursorPosition()
Store.restoreTimeSelection()
Store.restoreItemSelection()

Common.updateArrange()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Manipulate")
