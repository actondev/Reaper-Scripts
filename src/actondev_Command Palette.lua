package.path = debug.getinfo(1,"S").source:match[[^@?(.*[\/])[^\/]-$]] .."?.lua;".. package.path

local Log = require('utils.log')
local Actions = require('utils.actions')
local Gui = require('utils.gui')
local Common = require('utils.common')

Log.isdebug = true

-- Actions.getActions(Actions.SECTION.MAIN, 10)
local res = Actions.search(Actions.SECTION.MAIN, 'split item', false)

if #res > 1 then
    Log.debug("first match: " .. res[1].name)
    -- Common.cmd(res[1].id)
end

Log.debug(Log.dump(res))

function init()
    gfx.init("actondev/Command Palette", 400, 100)
    Common.moveWindowToMouse()
end

function mainloop()
	if gfx.mouse_cap == 0 then
		if not hasClicked then
			-- initDraw()
		else
			-- release()
		end
	elseif gfx.mouse_cap == 1 then
		-- left click
		hasClicked = true
		clickDraw()
    end
    gfx.x =0
    gfx.y=0
    Gui.drawString("hi there")
	gfx.update()
	local c=gfx.getchar()
	if c~=Gui.CHAR.ESCAPE and c~=Gui.CHAR.EXIT then
		reaper.defer(mainloop)
	end
end


init()
mainloop()