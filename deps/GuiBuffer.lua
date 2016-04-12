GuiBuffer = class(function(self,id)
	self.id = id

	self.sizeX = 0
	self.sizeY = 0

	self.inStartX, self.InStartY = 0,0
	self.inEndX, self.InEndY = 0,0

	self.outStartX, self.outStartY = 0,0
	self.outEndX, self.outEndY = 0,0

	self.inW, self.inH = 0,0
	self.outW, self.outH = 0,0

	self.scrollX, self.scrollY = 0,0

end
)

function GuiBuffer:getId()
	return self.id
end

function GuiBuffer:clear()
	self.sizeX = 0
	self.sizeY = 0
	gfx.setimgdim(self.id, -1, -1)  
	gfx.setimgdim(self.id, 2048, 1024)
	-- gfx.clear=0
	-- gfx.rect(0,0,gfx.getimgdim(self.id))
end

-- set the size of the frame's contents
function GuiBuffer:setInSize(w, h)
	self.inW = w
	self.inH = h
	-- fdebug("inSize H ".. h)
	-- gfx.setimgdim(self.id, 1024, 1024)
	-- return 1024, 1024
end
-- getter
function GuiBuffer:inSize()
	return self.inW, self.inH
end

-- set the size of the frame's contents
function GuiBuffer:setOutSize(w, h)
	self.outW = w
	self.outH = h
	-- gfx.setimgdim(self.id, 1024, 1024)
	-- return 1024, 1024
end
-- ^getter
function GuiBuffer:outSize()
	return self.outW, self.outH
end

-- set the x,y of the place where it gets drawn
function GuiBuffer:setOutStart(x,y)
	self.outStartX = x
	self.outStartY = y
end
-- getter ^
function GuiBuffer:outStart()
	return self.outStartX, self.outStartY
end

-- set the x,y of the right/bottom borders where it gets drawn
function GuiBuffer:setOutEnd(x,y)
	self.outEndX = x
	self.outEndY = y
	self:setOutSize(x-self.outStartX, y-self.outStartY)
end
function GuiBuffer:outEnd()
	return self.outEndX, self.outEndY
end

-- get maximum x scroll
function GuiBuffer:maxScrollX(scrollStep)
	return math.max( self.inW - self.outW ,0)
end

function GuiBuffer:blitSize()
	return gfx.getimgdim(self.id)
end

function GuiBuffer:setScroll(x,y)
	if y==nil then y=0 end
	self.scrollX, self.scrollY = x, y
end

function GuiBuffer:mouseOffset()
	return self.outStartX-self.scrollX, self.outStartY-self.scrollY
end