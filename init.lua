mail = {

	-- mark webmail fork for other mods
	fork = "webmail",

	-- api version
	apiversion = 1.1,

	-- mail directory
	maildir = minetest.get_worldpath().."/mails",

	-- allow item/node attachments
	allow_attachments = minetest.settings:get("mail.allow_attachments") == "true",

	webmail = {
		-- disallow banned players in the webmail interface
		disallow_banned_players = minetest.settings:get("webmail.disallow_banned_players") == "true",

		-- url and key to the webmail server
		url = minetest.settings:get("webmail.url"),
		key = minetest.settings:get("webmail.key")
	},

	tan = {}
}


local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/chatcommands.lua")
dofile(MP .. "/migrate.lua")
dofile(MP .. "/attachment.lua")
dofile(MP .. "/hud.lua")
dofile(MP .. "/storage.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/gui.lua")
dofile(MP .. "/onjoin.lua")

-- optional webmail stuff below

--[[ minetest.conf
secure.http_mods = mail
webmail.url = http://127.0.0.1:8080
webmail.key = myserverkey
--]]

local http = minetest.request_http_api()

if http then
	local webmail_url = mail.webmail.url
	local webmail_key = mail.webmail.key

	if not webmail_url then error("webmail.url is not defined") end
	if not webmail_key then error("webmail.key is not defined") end

	print("[mail] loading webmail-component with endpoint: " .. webmail_url)
	dofile(MP .. "/tan.lua")
	dofile(MP .. "/webmail.lua")
	mail.webmail_init(http, webmail_url, webmail_key)
end

-- migrate storage
mail.migrate()
