-- package.path = reaper.GetResourcePath()..'/Scripts/?.lua;' .. package.path
-- reaper.ShowConsoleMsg(package.path)
require 'Scripts.Actondev.deps.template'
require 'Scripts.Actondev.deps.region'

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