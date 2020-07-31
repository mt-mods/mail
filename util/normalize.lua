--[[
return the field normalized (comma separated, single space)
and add individual player names to recipient list
--]]
function normalize_players_and_add_recipients(field, recipients)
    local separator = ", "
    local pattern = "([^" .. separator .. "]+)"

    -- get individual players
    local player_set = {}
    local order = {}
    field:gsub(pattern, function(c)
        if player_set[string.lower(c)] ~= nil then
            player_set[string.lower(c)] = c
            order[#order+1] = c

            -- also sort into recipients
            if recipients[string.lower(c)] ~= nil then
                recipients[string.lower(c)] = c
            end
        end
    end)

    -- turn list of players back into normalized string
    return table.concat(order, ", ")
end
