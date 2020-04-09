local module = {}

module.ALIGN = {
    RIGHT = 'right',
    LEFT = 'left'
}

module.CHAR = {
	EXIT = -1,
	ESCAPE = 27,
}

function module.drawString(text, align)
	local tempY = gfx.y
	local textH = gfx.texth
	if(align == module.ALIGN.RIGHT) then
		gfx.x = gfx.x - gfx.measurestr(text)
	end
	gfx.y = gfx.y - textH/2
	gfx.printf(text)
	gfx.y = tempY
end

function module.drawRectBorder(x, y, w, h, borderWidth)
	if(borderWidth==1) then
		gfx.rect(x, y, w, h, 0)
		return
	end
	-- top 
	gfx.rect(x, y, w, borderWidth, 1)
	-- bottom
	gfx.rect(x, y+h-b, w, borderWidth, 1)
	-- left
	gfx.rect(x, y, borderWidth, h, 1)
	-- right
	gfx.rect(x+w-borderWidth, y, borderWidth, h, 1)
end


return module