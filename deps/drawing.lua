function drawString(text, align)
	local tempX = gfx.x
	local tempY = gfx.y
	local textH = gfx.texth
	if(align == "right") then
		gfx.x = gfx.x - gfx.measurestr(text)
	end
	gfx.y = gfx.y - textH/2
	gfx.printf(text)
	gfx.y = tempY
end

function drawRectBorder(x,y,w,h,b)
	if(b==1) then
		gfx.rect(x,y,w,h,0)
		return
	end
	-- top 
	gfx.rect(x,y,w,b,1)
	-- bottom
	gfx.rect(x,y+h-b,w,b,1)
	-- left
	gfx.rect(x,y,b,h,1)
	-- right
	gfx.rect(x+w-b,y,b,h,1)
end