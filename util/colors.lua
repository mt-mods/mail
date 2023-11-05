local function get_base_color(id)
    local colors = {
		h = "#999", -- header
		s = "#72FF63", -- selected
		i = "#FFD700", -- important
		a = "#CCCCDD", -- additional
		H = "#608631", -- highlighted
		n = "#00F529" -- new
	}
	return colors[id]
end

local function hex2rgb(hex)
    hex = hex:gsub("#","")
    return {
        r = tonumber("0x" .. hex:sub(1,2)),
        g = tonumber("0x" .. hex:sub(3,4)),
        b = tonumber("0x" .. hex:sub(5,6))
    }
end

local function rgb2hex(rgb)
    return "#" .. string.format("%x", rgb.r) .. string.format("%x", rgb.g) .. string.format("%x", rgb.b)
end

local function rgbColorsMix(colors)
    local R = 0
    local G = 0
    local B = 0
    for _, c in ipairs(colors) do
        R = R + c.r
        G = G + c.g
        B = B + c.b
    end
    R = R / #colors
    G = G / #colors
    B = B / #colors
    return {r=R,g=G,b=B}
end

function mail.get_color(mix)
    if #mix == 1 then
        return get_base_color(mix)
    else
        local colors = {}
        for i = 1, #mix do
            local c = mix:sub(i,i)
            colors[#colors+1] = hex2rgb(get_base_color(c))
        end
        local mixed_color = rgbColorsMix(colors)
        return rgb2hex(mixed_color)
    end
end
