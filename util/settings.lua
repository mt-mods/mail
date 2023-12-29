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
        type = "index", default = 3, group = "message_list", index = 3,
        label = S("Default sorting field"), dataset = { S("From/To"), S("Subject"), S("Date") }
    },
    defaultsortdirection = {
        type = "index", default = 1, group = "message_list", index = 4,
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
        type = "string", default = "%Y-%m-%d %X", group = "other", index = 3, label = S("Date format"),
        dataset = {"%Y-%m-%d %X", "%d/%m/%y %X", "%A %d %B %Y %X"}, format = os.date
    },
}

mail.settings_groups = {
    { name = "notifications", label = S("Notifications")},
    { name = "message_list",  label = S("Message list")},
    { name = "other",         label = S("Other")}
}

for s, d in pairs(mail.settings) do
	mail.selected_idxs[s] = {}
	if d.type == "list" then
        mail.selected_idxs["index_" .. s] = {}
    end
end
