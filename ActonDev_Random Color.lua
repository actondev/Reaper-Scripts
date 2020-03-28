package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
local Common = require('utils.common')
local Item = require('utils.item')
local Track = require('utils.track')

function main()
	local r = math.floor(math.random()*255)
	local g = math.floor(math.random()*255)
	local b = math.floor(math.random()*255)

	if Common.getEditContext() == Common.EDIT_CONTEXT.ITEM then
		local items = Item.selected()
		for _,item in pairs(items) do
			Item.paint(item, r, g, b)
		end
	elseif Common.getEditContext() == Common.EDIT_CONTEXT.TRAK then
		local tracks = Track.selected()
		for _,track in pairs(tracks) do
			Track.paint(track, r, g, b)
		end
	end
	-- need to update arrange after coloring
	Common.updateArrange()
end

Common.undoBeginBlock()
main()
Common.undoEndBlock("ActonDev: Random Color", -1)