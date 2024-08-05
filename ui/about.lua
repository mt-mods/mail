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
	mail.selected_idxs.contributor_grouping[name] = tonumber(mail.selected_idxs.contributor_grouping[name]) or 1

	local formspec = [[
			size[10,6;]
			tabheader[0,0;optionstab;]] .. S("Settings") .. "," .. S("About") .. [[;2;false;false]
			button[9.35,0;0.75,0.5;back;X]

			box[0,0;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[0.2,0;Mail]

			label[0.2,0.5;]] .. S("Provided by mt-mods") .. [[]
			label[0.2,0.9;]] .. S("Version: @1", "1.4.0") .. [[]

			box[0,1.5;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[0.2,1.5;]] .. S("Licenses") .. [[]
			label[0.2,2.0;]] .. S("Expat (code), WTFPL (textures)") .. [[]

			box[0,2.6;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[0.2,2.6;]] .. S("Note") .. [[]
			textarea[0.5,3.15;4,5.5;;;]] ..
			S("Communication using this system is NOT guaranteed to be private!") .. " " ..
			S("Admins are able to view the messages of any player.") .. [[]

			button[0,5.7;2,0.5;github;GitHub]
			button[2,5.7;2,0.5;contentdb;ContentDB]

			box[4,0;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[4.2,0;]] .. S("Contributors") .. [[]

			dropdown[4,0.75;6.4;contributor_grouping;]]
				.. S("Group by name") .. ","
				.. S("Group by contribution") .. ";" .. mail.selected_idxs.contributor_grouping[name] .. [[;true]
			]]

	local contributor_list, contributor_columns = {}

	if mail.selected_idxs.contributor_grouping[name] == 2 then
		contributor_columns = "color;text"
		local sorted = {}
		for _, g in ipairs(groups) do
			sorted[g[1]] = {}
		end
		for _, c in ipairs(contributors) do
			for _, g in ipairs(c.groups) do
				table.insert(sorted[g] or {}, c.name)
			end
		end
		for _, g in ipairs(groups) do
			table.insert(contributor_list, mail.get_color("header") .. "," .. g[2])
			for _, c in ipairs(sorted[g[1]]) do
				table.insert(contributor_list, "," .. c)
			end
		end
	else
		contributor_columns = "text;text"
		for _, c in ipairs(contributors) do
			for _, g in ipairs(groups) do
				local index = table.indexof(c.groups, g[1])
				if index >= 1 then
					if index == 1 then
						table.insert(contributor_list, c.name)
					else
						table.insert(contributor_list, "")
					end
					table.insert(contributor_list, g[2])
				end
			end
		end
	end

	formspec = formspec .. ("tablecolumns[%s]"):format(contributor_columns) ..
			("table[4,1.6;5.9,4.65;contributors;%s]"):format(table.concat(contributor_list, ","))

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
	elseif fields.contributor_grouping then
		mail.selected_idxs.contributor_grouping[playername] = fields.contributor_grouping
		mail.show_about(playername)
	end
end)
