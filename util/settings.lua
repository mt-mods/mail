-- translation
local S = minetest.get_translator("mail")

mail.settings = {
    chat_notifications = {
        type = "bool", default = true, group = "notifications", index = 1,
        label = S("Chat notifications"), tooltip = S("Receive a message in the chat when there is a new message")
    },
    onjoin_notifications = {
        type = "bool", default = true, group = "notifications", index = 2,
        label = S("On join notifications"), tooltip = S("Receive a message at login when inbox isn't empty") },
    hud_notifications = {
        type = "bool", default = true, group = "notifications", index = 3,
        label = S("HUD notifications"), tooltip = S("Show an HUD notification when inbox isn't empty")
    },
    sound_notifications = {
        type = "bool", default = true, group = "notifications", index = 4,
        label = S("Sound notifications"), tooltip = S("Play a sound when there is a new message")
    },
    unreadcolorenable = {
        type = "bool", default = true, group = "message_list", index = 1,
        label = S("Show unread in different color")
    },
    cccolorenable = {
        type = "bool", default = true, group = "message_list", index = 2,
        label = S("Show CC/BCC in different color")
    },
    defaultsortfield = {
        type = "index", default = 3, group = "box_fields", index = 1,
        label = S("Default sorting field"), dataset = { S("From/To"), S("Subject"), S("Date") }
    },
    defaultsortdirection = {
        type = "index", default = 1, group = "box_fields", index = 2,
        label = S("Default sorting direction"), dataset = { S("Ascending"), S("Descending") }
    },
    trash_move_enable = {
        type = "bool", default = true, group = "other", index = 1,
        label = S("Move deleted messages to trash")
    },
    auto_marking_read = {
        type = "bool", default = true, group = "other", index = 2,
        label = S("Automatic marking read"), tooltip = S("Mark a message as read when opened")
    },
    date_format = {
        type = "string", default = "%Y-%m-%d %X", group = "date_and_time", index = 3, label = S("Date format"),
        dataset = {"%Y-%m-%d %X", "%d/%m/%y %X", "%A %d %B %Y %X"}, format = os.date
    },
    timezone_offset = {
        type = "number", default = 0, group = "date_and_time", index = 4,
        label = S("Timezone offset"), tooltip = S("Offset to add to server time."),
    },
    mute_list = {
        type = "list", default = {}, group = "spam", index = 1,
        label = S("Mute list")
    },
}

mail.settings_groups = {
    { name = "notifications", label = S("Notifications"), index = 1, parent = 0},
    { name = "message_list",  label = S("Message list"),  index = 2, parent = 0},
    { name = "box_fields",    label = S("Fields"),        index = 1, parent = "message_list"},
    { name = "spam",          label = S("Spam"),          index = 3, parent = 0},
    { name = "other",         label = S("Other"),         index = 4, parent = 0},
    { name = "date_and_time", label = S("Date and Time"), index = 1, parent = "other"}
}

for s, d in pairs(mail.settings) do
	mail.selected_idxs[s] = {}
	if d.type == "list" then
        mail.selected_idxs["index_" .. s] = {}
    end
end

function mail.settings.mute_list.check(name, value)
    local valid_players = {}
    for _, p in ipairs(value) do
        if p ~= name and minetest.player_exists(p) then
            table.insert(valid_players, p)
        end
    end
    return valid_players
end

function mail.settings.mute_list.sync(name)
    if minetest.get_modpath("beerchat") then
        local players = {}
        for other_player, _ in minetest.get_auth_handler().iterate() do
            if beerchat.has_player_muted_player(name, other_player) then
                table.insert(players, other_player)
            end
        end
        return players
    end
    return nil
end

function mail.settings.mute_list.transfer(name, value)
    if minetest.get_modpath("beerchat") then
        for other_player, _ in minetest.get_auth_handler().iterate() do -- unmute all
            if not beerchat.execute_callbacks("before_mute", name, other_player) then
                return false
            end
            minetest.get_player_by_name(name):get_meta():set_string(
				"beerchat:muted:" .. other_player, "")
        end
        for _, other_player in ipairs(value) do -- then mute only players in table
            minetest.get_player_by_name(name):get_meta():set_string(
                    "beerchat:muted:" .. other_player, "true")
        end
        return true
    end
    return nil
end
