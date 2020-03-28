
package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Log = require('utils.log')
local RegionItems = require('utils.region_items')

Log.isdebug = true

local regionItem = reaper.GetSelectedMediaItem(0, 0)

RegionItems.select(regionItem)