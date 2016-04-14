package.path = reaper.GetResourcePath().. package.config:sub(1,1) .. '?.lua;' .. package.path
require 'Scripts.ActonDev.deps.template'
require 'Scripts.ActonDev.deps.region'

debug_mode = 0

-- remove time selection
reaperCMD(40635)
-- unselect all tracks
reaperCMD(40297)
-- unselect all items
reaperCMD(40289)
-- envelope: unselect all points
reaperCMD(40331)

-- region items: cleanup placeholder items inserted for envelope copy fix
mediaItemGarbageClean()