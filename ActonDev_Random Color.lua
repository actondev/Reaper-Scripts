require 'Scripts.Actondev.deps.template'
require 'Scripts.Actondev.deps.colors'
debug_mode = 0

label = "ActonDev: Random Color"

-- function colorize in actondev.template

function mainActions()
	if reaper.GetCursorContext2(true) == 1 then
		-- item
		-- item: set to one random color
		reaperCMD(40706)
		-- sometimes required if it's wave/midi item (required with takes etc)
		-- set active takes to one random color
		reaperCMD(41332)

	else
		-- track
		reaperCMD(40360)
	end
end

function main()
	r = math.floor(math.random()*255)
	g = math.floor(math.random()*255)
	b = math.floor(math.random()*255)

	colorize(true, r, g, b)
	TcpRedraw()
end

reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock(label, -1)

reaper.UpdateArrange()