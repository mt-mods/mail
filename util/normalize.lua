local S = minetest.get_translator("mail")

local function recursive_expand_recipient_names(sender, list, is_toplevel, recipients, undeliverable)
    for _, name in ipairs(list) do
        if not (recipients[name] or undeliverable[name] or (name == sender and not is_toplevel)) then
            local succ, value
            for _, handler in ipairs(mail.registered_recipient_handlers) do
                succ, value = handler(sender, name)
                if succ ~= nil then
                    break
                end
            end
            local vtp = type(value)
            if succ then
                if vtp == "string" then
                    recursive_expand_recipient_names(sender, {value}, false, recipients, undeliverable)
                elseif vtp == "table" then
                    recursive_expand_recipient_names(sender, value, false, recipients, undeliverable)
                elseif vtp == "function" then
                    recipients[name] = value
                else
                    undeliverable[name] = S("The method of delivery to @1 is invalid.", name)
                end
            elseif succ == nil then
                undeliverable[name] = S("The recipient @1 could not be identified.", name)
            else
                local reason = tostring(value) or S("@1 rejected your mail.", name)
                undeliverable[name] = reason
            end
        end
    end
end

--[[
return the field normalized (comma separated, single space)
and add individual player names to recipient list
--]]
function mail.normalize_players_and_add_recipients(sender, field, recipients, undeliverable)
    local order = mail.parse_player_list(field)
    recursive_expand_recipient_names(sender, order, true, recipients, undeliverable)
    return mail.concat_player_list(order)
end

function mail.parse_player_list(field)
    if not field then
        return {}
    end

    local separator = ",%s"
    local pattern = "([^" .. separator .. "]+)"

    -- get individual players
    local order = {}
    for name in field:gmatch(pattern) do
        table.insert(order, name)
    end

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
