mail = {
	-- api version
	apiversion = 1.1,

	-- mail directory
	maildir = minetest.get_worldpath().."/mails",
	contactsdir = minetest.get_worldpath().."/mails/contacts"
}


local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/util/normalize.lua")
dofile(MP .. "/chatcommands.lua")
dofile(MP .. "/migrate.lua")
dofile(MP .. "/hud.lua")
dofile(MP .. "/storage.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/gui.lua")
dofile(MP .. "/onjoin.lua")

-- migrate storage
mail.migrate()

if minetest.get_modpath("mtt") then
	dofile(MP .. "/mtt.lua")
end