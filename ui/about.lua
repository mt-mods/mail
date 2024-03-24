-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:about"

function mail.show_about(name)
	local formspec = [[
			size[10,6;]
			tabheader[0,0;optionstab;]] .. S("Settings") .. "," .. S("About") .. [[;2;false;false]
			button[9.35,0;0.75,0.5;back;X]

			box[0,0;3,0.45;]] .. mail.get_color("highlighted") .. [[]
			label[0.2,0;Mail]

			label[0.2,0.5;]] .. S("Provided by mt-mods") .. [[]
			label[0.2,0.9;]] .. S("Version") .. [[ : 1.4.0-dev]

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

			tablecolumns[color;text;text]
			table[4,0.75;5.9,5.5;contributors;]] ..
			mail.get_color("header") .. [[,]] .. S("Contributors") .. [[,,]] ..
			mail.get_color("important") .. [[,Cheapie,Initial idea/project,]] ..
			[[,Rubenwardy,Lua/UI improvements,]] ..
			[[,BuckarooBanzay,Clean-ups\, Refactoring,]] ..
			[[,Athozus,Boxes\, Maillists\, UI\, Settings,]] ..
			[[,fluxionary,Minor fixups,]] ..
			[[,SX,Various fixes\, UI,]] ..
			[[,Toby1710,UX fixes,]] ..
			[[,Peter Nerlich,CC\, BCC,]] ..
			[[,Niklp,German translation,]] ..
			[[,Emojigit,Traditional Chinese trans.,]] ..
			[[,Dennis Jenkins,UX fixes,]] ..
			[[,Thomas Rudin,Maintenance,]] ..
			[[,NatureFreshMilk,Maintenance,]] ..
			[[,imre84,UI fixes,]] ..
			[[,Chache,Spanish translation,]] ..
			[[,APercy,Brazilian Portuguese trans.,]] ..
			[[,Nuno Filipe Povoa,mail_notif.ogg,]] ..
			[[,TheTrueBeginner,Simplified Chinese trans.,]] ..
			[[,nyomi,Hungarian translation,]] ..
			[[,whosit,UI fixes,]] ..
			[[,Wuzzy,German translation,]] ..
			[[,Muhammad Rifqi Priyo Susanto,Indonesian trans.]
		]] .. mail.theme

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
