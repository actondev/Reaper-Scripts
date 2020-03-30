package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Log = require('utils.log')
local Actions = require('utils.actions')
local Common = require('utils.common')

Log.isdebug = true

-- Actions.getActions(Actions.SECTION.MAIN, 10)
local res = Actions.search(Actions.SECTION.MAIN, 'split item', false)

if #res > 1 then
    Log.debug("first match: " .. res[1].name)
    -- Common.cmd(res[1].id)
end

Log.debug(Log.dump(res))