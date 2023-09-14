-- translation
local S = minetest.get_translator("mail")

mail = {
	-- version
	version = 3,

	-- mod storage
	storage = minetest.get_mod_storage(),

	-- ui theme prepend
	theme = "",

	-- ui forms
	ui = {},

	-- per-user ephemeral data
	selected_idxs = {
		inbox = {},
		outbox = {},
		drafts = {},
		trash = {},
		contacts = {},
		maillists = {},
		to = {},
		cc = {},
		bcc = {},
		boxtab = {},
		sortfield = {},
		sortdirection = {},
		filter = {},
		multipleselection = {},
		optionstab = {},
		settings_group = {},
	},

	colors = {
		header = "#999",
		selected = "#72FF63",
		important = "#FFD700",
		additional = "#CCCCDD",
		imp_sel = "#B9EB32",
		add_sel = "#9FE6A0",
		imp_add = "#E6D26F",
		imp_add_sel = "#BFE16B",
		highlighted = "#608631",
		new = "#00F529"
	},

	settings = {
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
	},

	settings_groups = {
		{ name = "notifications", label = S("Notifications")},
		{ name = "message_list",  label = S("Message list")},
		{ name = "other",         label = S("Other")}
	},

	message_drafts = {}
}

for s, _ in pairs(mail.settings) do
	mail.selected_idxs[s] = {}
end

if minetest.get_modpath("default") then
	mail.theme = default.gui_bg .. default.gui_bg_img
end

-- sub files
local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/chatcommands.lua")
dofile(MP .. "/migrate.lua")
dofile(MP .. "/hud.lua")
dofile(MP .. "/storage.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/gui.lua")
dofile(MP .. "/onjoin.lua")
-- sub directories
dofile(MP .. "/ui/init.lua")
dofile(MP .. "/util/init.lua")

-- migrate storage
mail.migrate()

if minetest.get_modpath("mtt") then
	dofile(MP .. "/mtt.lua")
	dofile(MP .. "/api.spec.lua")
	dofile(MP .. "/migrate.spec.lua")
	dofile(MP .. "/util/uuid.spec.lua")
	dofile(MP .. "/util/normalize.spec.lua")
end
