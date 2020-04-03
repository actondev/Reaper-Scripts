local module = {}
local Class = require("utils.class")

module = {
    frame = 0,
    mouse = {
        x = 0,
        y = 0,
        px = 0,
        py = 0
    },
    modifiers = {
        none = true,
        control = false,
        alt = false,
        shit = false
    }
}

function module.pre_draw()
    module.char = gfx.getchar()
    module.mouse.x = gfx.mouse_x
    module.mouse.y = gfx.mouse_y
    if
        gfx.mouse_cap & 1 == 1 and last_mouse_cap & 1 == 0 or -- L mouse
            gfx.mouse_cap & 2 == 2 and last_mouse_cap & 2 == 0 or -- R mouse
            gfx.mouse_cap & 64 == 64 and last_mouse_cap & 64 == 0
     then -- M mouse
        mouse_ox, mouse_oy = gfx.mouse_x, gfx.mouse_y
    end

    module.modifiers.none = gfx.mouse_cap == 0
    module.modifiers.control = gfx.mouse_cap & 4 > 0
    module.modifiers.shift = gfx.mouse_cap & 8 > 0
    module.modifiers.alt = gfx.mouse_cap & 16 > 0

end

function module.post_draw()
    module.frame = module.frame + 1
    module.mouse.px = module.mouse.x
    module.mouse.py = module.mouse.y
end

module.Element = Class.new()

function module.Element:new(opts)
    self.data = opts
    return self
end

-- draw a rect with a border width (bw)
-- the border is inset : the final rect will not be drawn outside of x,y and x+w, y+h
local function draw_border(x, y, w, h, width)
    if width == 0 then
        return
    end
    if width == 1 then
        gfx.rect(x, y, w, h, false)
    end
    -- if width > 1 then we call gfx.rect with the flag fill set to true
    -- left
    gfx.rect(x, y, width, h, true)
    -- right
    gfx.rect(x + w - width, y, width, h, true)
    -- top
    gfx.rect(x, y, w, width, true)
    -- right
    gfx.rect(x, y + h - width, w, width, true)
end

function module.Element:draw_border()
    if self.data.border == nil then
        return
    end
    local v = self.data.border
    gfx.r = v.r
    gfx.g = v.g
    gfx.b = v.b
    gfx.a = v.a or 1
    local width = v.width or 1

    local d = self.data
    draw_border(d.x, d.y, d.w, d.h, width)
    -- gfx.rect(d.x, d.y, d.w, d.h, false) -- frame1
end

function module.Element:draw_background()
    if self.data.bg == nil then
        return
    end
    local v = self.data.bg
    gfx.r = v.r
    gfx.g = v.g
    gfx.b = v.b
    gfx.a = v.a or 1

    local d = self.data
    gfx.rect(d.x, d.y, d.w, d.h, true) -- frame1
end

function module.Element:draw()
    self:draw_background()
    self:draw_border()
end

module.Button = Class.extend(module.Element)

return module
