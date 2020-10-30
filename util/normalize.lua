--[[
return the field normalized (comma separated, single space)
and add individual player names to recipient list
--]]
function mail.normalize_players_and_add_recipients(field, recipients)
    local order = mail.parse_player_list(field)
    for _, c in ipairs(order) do
        if recipients[string.lower(c)] == nil then
            recipients[string.lower(c)] = c
        end
    end
    return mail.concat_player_list(order)
end


function mail.parse_player_list(field)
    if not field then
        return {}
    end

    local separator = ", "
    local pattern = "([^" .. separator .. "]+)"

    -- get individual players
    local player_set = {}
    local order = {}
    field:gsub(pattern, function(c)
        if player_set[string.lower(c)] == nil then
            player_set[string.lower(c)] = c
            order[#order+1] = c
        end
    end)

    return order
end

function mail.concat_player_list(order)
    -- turn list of players back into normalized string
    return table.concat(order, ", ")
end

function mail.player_in_list(name, list)
    list = list or {}
    if type(list) == "string" then
        list = mail.parse_player_list(list)
    end
    for _, c in pairs(list) do
        if name == c then
            return true
        end
    end
    return false
end


function mail.ensure_new_format(message, name)
    if message.to == nil then
        message.to = name
    end
end
