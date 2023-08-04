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
		chat_notifications = {},
		onjoin_notifications = {},
		hud_notifications = {},
		sound_notifications = {},
		unreadcolorenable = {},
		cccolorenable = {},
		trash_move_enable = {},
		auto_marking_read = {},
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
		chat_notifications		= { type = "bool",		default = true,				group = "notifications" },
		onjoin_notifications	= { type = "bool",		default = true,				group = "notifications" },
		hud_notifications		= { type = "bool",		default = true,				group = "notifications" },
		sound_notifications		= { type = "bool",		default = true,				group = "notifications" },
		unreadcolorenable		= { type = "bool",		default = true,				group = "message_list" },
		cccolorenable			= { type = "bool",		default = true,				group = "message_list" },
		defaultsortfield		= { type = "number",	default = 3,				group = "message_list" },
		defaultsortdirection	= { type = "number",	default = 1,				group = "message_list" },
		trash_move_enable		= { type = "bool",		default = true,				group = "other" },
		auto_marking_read		= { type = "bool",		default = true,				group = "other" },
		date_format				= { type = "string",	default = "%Y-%m-%d %X",	group = "other" },
	},

	settings_groups = {
		notifications	= S("Notifications"),
		message_list	= S("Message list"),
		other			= S("Other")
	}

	message_drafts = {}
}

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
