package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local RegionItems = require('utils.region_items')
local Log = require('utils.log')
local Item = require('utils.item')
local Json = require('lib.json')
local Common = require('utils.common')
local Store = require('utils.store')
local Parse = require('utils.parse')
local ItemManipulation = require('utils.item_manipulation')
local regionItem = reaper.GetSelectedMediaItem(0, 0)

Common.undoBeginBlock()
Common.preventUIRefresh(1)
Store.storeCursorPosition()
RegionItems.select(regionItem)
local notes = Item.notes(regionItem)
-- Log.isdebug = true
-- Log.debug("notes")
-- Log.debug(notes)

local manipulationOpts = Parse.parsedTaggedJson(notes, ItemManipulation.TAG_V1)

ItemManipulation.manipulateSelected(manipulationOpts)

Item.unselectAll()
Item.setSelected(regionItem, true)
Common.updateArrange()

Store.restoreCursorPosition()
Common.preventUIRefresh(-1)
Common.undoEndBlock("actondev/Region Item: Manipulate")
