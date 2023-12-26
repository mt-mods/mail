local generic_colors = {
	header         = "#999999",
	selected       = "#72FF63",
	important      = "#FFD700",
	additional     = "#CCCCDD",
	highlighted    = "#608631",
	new            = "#00F529",
	warning        = "#FF8800",
	disabled       = "#332222",
}

local function get_base_color(c)
    return generic_colors[c] or ""
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
    R = math.floor(R / #colors + 0.5)
    G = math.floor(G / #colors + 0.5)
    B = math.floor(B / #colors + 0.5)
    return {r=R,g=G,b=B}
end

function mail.get_color(mix)
    if type(mix) == "string" then
        return get_base_color(mix)
    elseif #mix == 1 then
        return get_base_color(mix[1])
    else
        local colors2mix = {}
        for _, c in ipairs(mix) do
            colors2mix[#colors2mix+1] = hex2rgb(get_base_color(c))
        end
        local mixed_color = rgbColorsMix(colors2mix)
        return rgb2hex(mixed_color)
    end
end
