local has_canonical_name = minetest.get_modpath("canonical_name")

--[[
return the field normalized (comma separated, single space)
and add individual player names to recipient list
--]]
function mail.normalize_players_and_add_recipients(field, recipients, undeliverable)
    local order = mail.parse_player_list(field)
    for _, recipient_name in ipairs(order) do
        if not minetest.player_exists(recipient_name) then
            undeliverable[recipient_name] = true
        else
            recipients[recipient_name] = true
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
    field:gsub(pattern, function(player_name)
        local lower = string.lower(player_name)
        if not player_set[lower] then
            if has_canonical_name then
                player_name = canonical_name.get(player_name) or player_name
            end

            player_set[lower] = player_name
            order[#order+1] = player_name
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
    for _, player_name in pairs(list) do
        if name == player_name then
            return true
        end
    end
    return false
end
