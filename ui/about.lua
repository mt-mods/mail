-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:about"

local groups = {
	{ "o", S("Original author")},
	{ "c", S("Code")},
	{ "i", S("Internationalization")},
	{ "t", S("Textures")},
	{ "a", S("Audio")},
}

local contributors = {
	{ name = "Cheapie", groups = {"o", "c"} },
	{ name = "aBlueShadow", groups = {"c"} },
	{ name = "APercy", groups = {"i"} },
	{ name = "Athozus", groups = {"c", "i"} },
	{ name = "BuckarooBanzay", groups = {"c"} },
	{ name = "Chache", groups = {"i"} },
	{ name = "Dennis Jenkins", groups = {"c"} },
	{ name = "Emojigit", groups = {"i"} },
	{ name = "Eredin", groups = {"i"} },
	{ name = "fluxionary", groups = {"c"} },
	{ name = "imre84", groups = {"c"} },
	{ name = "Muhammad Rifqi Priyo Susanto", groups = {"i"} },
	{ name = "NatureFreshMilk", groups = {"c", "t"} },
	{ name = "Niklp", groups = {"c", "i"} },
	{ name = "Nuno Filipe Povoa", groups = {"a"} },
	{ name = "nyomi", groups = {"i"} },
	{ name = "OgelGames", groups = {"c"} },
	{ name = "Panquesito7", groups = {"c"} },
	{ name = "Peter Nerlich", groups = {"c"} },
	{ name = "Rubenwardy", groups = {"c"} },
	{ name = "savilli", groups = {"c"} },
	{ name = "Singularis", groups = {"c"} },
	{ name = "SX", groups = {"c"} },
	{ name = "TheTrueBeginner", groups = {"i"} },
	{ name = "Thomas Rudin", groups = {"c"} },
	{ name = "Toby1710", groups = {"c"} },
	{ name = "whosit", groups = {"c"} },
	{ name = "Wuzzy", groups = {"i"} },
	{ name = "y5nw", groups = {"c", "i"} },
}

function mail.show_about(name)
	local formspec = [[
			size[10,6;]
			tabheader[0,0;optionstab;]] .. S("Settings") .. "," .. S("About") .. [[;2;false;false]
			button[9.35,0;0.75,0.5;back;X]

			box[0,0;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[0.2,0;Mail]

			label[0.2,0.5;]] .. S("Provided by mt-mods") .. [[]
			label[0.2,0.9;]] .. S("Version: @1", "1.4.0-dev") .. [[

			box[0,1.5;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[0.2,1.5;]] .. S("Licenses") .. [[]
			label[0.2,2.0;]] .. S("Expat (code), WTFPL (textures)") .. [[]

			box[0,2.6;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[0.2,2.6;]] .. S("Note") .. [[]
			textarea[0.5,3.1;4,5.5;;;]] ..
			S("Communication using this system is NOT guaranteed to be private!") .. " " ..
			S("Admins are able to view the messages of any player.") .. [[]

			button[0,5.7;2,0.5;github;GitHub]
			button[2,5.7;2,0.5;contentdb;ContentDB]

			box[4,0;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[4.2,0;]] .. S("Contributors") .. [[]

			tablecolumns[text;text]
			table[4,0.75;5.9,5.5;contributors;]]

	for _, c in ipairs(contributors) do
		formspec = formspec .. c.name
		for _, g in ipairs(groups) do
			if table.indexof(c.groups, g[1]) >= 1 then
				formspec = formspec .. "," .. g[2] .. ","
			end
		end
	end

	formspec = string.sub(formspec, 2, -2) -- remove last blank line
	formspec = formspec .. mail.theme

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

    local playername = player:get_player_name()

	if fields.back then
		mail.show_mail_menu(playername)

    elseif fields.optionstab == "1" then
        mail.selected_idxs.optionstab[playername] = 1
        mail.show_settings(playername)

    elseif fields.optionstab == "2" then
        mail.selected_idxs.optionstab[playername] = 2
        mail.show_about(playername)

	elseif fields.github then
		minetest.chat_send_player(playername, "https://github.com/mt-mods/mail")

	elseif fields.contentdb then
		minetest.chat_send_player(playername, "https://content.minetest.net/packages/mt-mods/mail")
	end
end)
