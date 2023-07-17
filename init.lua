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

	message_drafts = {}
}

if minetest.get_modpath("default") then
	mail.theme = default.gui_bg .. default.gui_bg_img
end

-- sub files
local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/util/normalize.lua")
dofile(MP .. "/util/contact.lua")
dofile(MP .. "/util/uuid.lua")
dofile(MP .. "/util/time_ago.lua")
dofile(MP .. "/chatcommands.lua")
dofile(MP .. "/migrate.lua")
dofile(MP .. "/hud.lua")
dofile(MP .. "/storage.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/gui.lua")
dofile(MP .. "/onjoin.lua")
dofile(MP .. "/ui/mail.lua")
dofile(MP .. "/ui/inbox.lua")
dofile(MP .. "/ui/outbox.lua")
dofile(MP .. "/ui/drafts.lua")
dofile(MP .. "/ui/trash.lua")
dofile(MP .. "/ui/message.lua")
dofile(MP .. "/ui/receivers.lua")
dofile(MP .. "/ui/events.lua")
dofile(MP .. "/ui/contacts.lua")
dofile(MP .. "/ui/edit_contact.lua")
dofile(MP .. "/ui/select_contact.lua")
dofile(MP .. "/ui/maillists.lua")
dofile(MP .. "/ui/edit_maillists.lua")
dofile(MP .. "/ui/compose.lua")
dofile(MP .. "/ui/options.lua")
dofile(MP .. "/ui/settings.lua")
dofile(MP .. "/ui/about.lua")

-- migrate storage
mail.migrate()

if minetest.get_modpath("mtt") then
	dofile(MP .. "/mtt.lua")
	dofile(MP .. "/api.spec.lua")
	dofile(MP .. "/migrate.spec.lua")
	dofile(MP .. "/util/uuid.spec.lua")
	dofile(MP .. "/util/normalize.spec.lua")
end
