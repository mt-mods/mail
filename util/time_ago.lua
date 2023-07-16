-- translation
local S = minetest.get_translator("mail")

function mail.time_ago(t)
    local elapsed = os.time() - t
    local str = ""

    local time_units = {
    { S("years"), 31536000 },
    { S("months"), 2592000 },
    { S("weeks"), 604800 },
    { S("days"), 86400 },
    { S("hours"), 3600 },
    { S("minuts"), 60 },
    { S("seconds"), 1 },
    }

    for _, u in ipairs(time_units) do
        local n = math.modf(elapsed/u[2])
        if n > 0 then
            str = str .. " " .. n .. " " .. u[1]
            elapsed = elapsed - n * u[2]
        end
    end

    str = string.sub(str, 2, -1)

    return S("@1 ago", str)
end
