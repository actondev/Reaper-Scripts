local module = {}

-- returns the reaper color value: to be set as track/take info value
function module.reaperValue(r, g, b)
    local colorNative = reaper.ColorToNative(r,g,b)
    local value = colorNative|0x1000000

    return value
end

local function shortIf(condition, if_true, if_false)
    if condition then return if_true else return if_false end
end

--[[
    Source http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
    - inputs R,G,B: 0-1 range
    - outputs H, S, L
      - H: Hue
      - S: Saturation
      - L: Lightness
]]
function RGB2HSL(R,G,B)
	local max = math.max(R,G,B)
	local min = math.min(R,G,B)
	local H,S,L
	H=(max+min)/2;S=H;L=H

	if max == min then
		-- achromatic
		H = 0
		S = 0
	else
		local d = max-min
		-- calculating S
		-- Functional-if
		S = shortIf(L>0.5, d/(2-max-min), d/(max+min) )
		-- switch max
		if max == R then
			H = (G - B) / d + shortIf(G < B,6,0)
		elseif max == G then
			H = (B-R)/d+2
		else
			H = (R-G)/d + 4
		end
		-- calculating H
		H = H/6;
	end
	return H,S,L
end

function module.HSL2RGB(H,S,L)
	-- R,G,B outputs: 0-1 range
	local R, G, B
	if S == 0 then
		R=L;G=L;B=L
	else
		local q = shortIf(L<0.5, L*(1+S), L+S-L*S)
		local p = 2*L - q
		R = hue2RGB(p, q, H+1/3)
		G = hue2RGB(p, q, H)
		B = hue2RGB(p, q, H-1/3)
	end
	return R,G,B
end

function module.adjustLight(R,G,B,adjust)
	-- colorDebug("RGB input",R,G,B)
	local H,S,L = RGB2HSL(R,G,B)
	-- colorDebug("HSL",H,S,L)
	L=L+adjust
	if L>1 then
		L=1
	elseif L<0 then
		L=0
	end
	R,G,B = HSL2RGB(H,S,L)
	-- colorDebug("RGB plus " .. adjust,R,G,B)
	return R,G,B
end

return module