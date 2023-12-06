-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:about"

function mail.show_about(name)
	local formspec = [[
			size[10,6;]
			tabheader[0.3,0.875;optionstab;]] .. S("Settings") .. "," .. S("About") .. [[;2;false;false]
			button[9.35,0;0.75,0.5;back;X]
			label[0,0.7;Mail]
			label[0,1.1;]] .. S("Provided by mt-mods") .. [[]
			label[0,1.5;]] .. S("Version") .. [[ : 1.3.0]
			label[0,2.0;]] .. S("Licenses") .. [[ :]
			label[0.2,2.4;]] .. S("Expat (code), WTFPL (textures)") .. [[]
			label[0,3.2;https://github.com/mt-mods/mail]
			label[0,3.6;https://content.minetest.net/packages/mt-mods/mail]
			textarea[0.5,4.8;4,5.5;;]] .. S("Note") .. [[;]] ..
			S("Communication using this system is NOT guaranteed to be private!") .. " " ..
			S("Admins are able to view the messages of any player.") .. [[]

			tablecolumns[color;text;text]
			table[5,0.75;4.9,5.5;contributors;]] ..
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
	end
end)
