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
		sent = {},
		contacts = {},
		maillists = {},
		to = {},
		cc = {},
		bcc = {},
		boxtab = {}
	},

	message_drafts = {}
}

if minetest.get_modpath("default") then
	mail.theme = default.gui_bg .. default.gui_bg_img
end

local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/util/normalize.lua")
dofile(MP .. "/util/uuid.lua")
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
dofile(MP .. "/ui/message.lua")
dofile(MP .. "/ui/contacts.lua")
dofile(MP .. "/ui/edit_contact.lua")
dofile(MP .. "/ui/select_contact.lua")
dofile(MP .. "/ui/maillists.lua")
dofile(MP .. "/ui/edit_maillists.lua")
dofile(MP .. "/ui/compose.lua")
dofile(MP .. "/ui/about.lua")

-- migrate storage
mail.migrate()

if minetest.get_modpath("mtt") then
	dofile(MP .. "/mtt.lua")
	dofile(MP .. "/api.spec.lua")
	dofile(MP .. "/util/uuid.spec.lua")
	dofile(MP .. "/util/normalize.spec.lua")
end
