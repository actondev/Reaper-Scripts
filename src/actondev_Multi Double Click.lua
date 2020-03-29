package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Common = require('utils.common')
local Item = require('utils.item')
local Log = require('utils.log')
local RegionItem = require('utils.region_items')
local ItemManipulation = require('utils.item_manipulation')
local Parse = require('utils.parse')
local Store = require('utils.store')
Log.isdebug = true

local undoText = 'actondev/Multi double click'

function main()
	local item = Item.firstSelected()

	local itemType = Item.type(item)

	-- when I create region items I add a pan envelope.. thus I can distinguish them by this
	if itemType == Item.TYPE.MIDI and Item.hasActiveTakeEnvelope(item, Item.TAKE_ENV.PAN) then
		RegionItem.select(item)
		undoText = 'actondev/Region Item: select'
	elseif itemType == Item.TYPE.EMPTY then
		-- apply region manipulation
		RegionItem.select(item)
		local opts = Parse.parsedTaggedJson(Item.notes(item), ItemManipulation.TAG_V1)
		ItemManipulation.manipulateSelected(opts)
		undoText =  'actondev/Region Item: manipulate'
	elseif itemType == Item.TYPE.MIDI then
		-- built-in midi editor
		-- 	label = "ActonDev: Open Midi item"
		undoText = "Open Midi Editor"
		Common.cmd(40153)
	elseif itemType == Item.TYPE.AUDIO then
		-- Item properties: Show media item/take properties
		undoText = "Open Audio Item Properties"
		Common.cmd(40009)
	end
end

if(reaper.CountSelectedMediaItems(0) > 0) then
	Common.undoBeginBlock()
	Common.preventUIRefresh(1)
	Store.storeTimeSelection()
	main()
	Store.restoreTimeSelection()
	Common.preventUIRefresh(-1)
	Common.undoEndBlock(undoText)
end