package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path
local Common = require('utils.common')

Common.undoBeginBlock()
-- remove time selection
Common.cmd(40635)
-- unselect all tracks
Common.cmd(40297)
-- unselect all items
Common.cmd(40289)
-- envelope: unselect all points
Common.cmd(40331)

Common.undoEndBlock('actondev/Escape')