-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:about"

function mail.show_about(name)
	local formspec = [[
			size[10,6;]
			tabheader[0.3,1;optionstab;]] .. S("Settings") .. "," .. S("About") .. [[;2;false;false]
			button[9.35,0;0.75,0.5;back;X]
			label[0,0.8;Mail]
			label[0,1.2;]] .. S("Provided my mt-mods") .. [[]
			label[0,1.6;]] .. S("Version") .. [[ : 1.2.0-dev]
			label[0,2.2;]] .. S("Licenses") .. [[ :]
			label[0.2,2.6;]] .. S("Expat (code), WTFPL (textures)") .. [[]
			label[0,3.2;https://github.com/mt-mods/mail]
			label[0,3.6;https://content.minetest.net/packages/mt-mods/mail]
			textarea[0.5,4.8;4,5.5;;]] .. S("Note") .. [[;]] ..
			S("Communication using this system is NOT guaranteed to be private!") .. " " ..
			S("Admins are able to view the messages of any player.") .. [[]

			tablecolumns[color;text;text]
			table[5,0.75;4.9,5.5;contributors;]] ..
			[[#999,]] .. S("Contributors") .. [[,,]] ..
			[[#FFD700,Cheapie,Initial idea/project,]] ..
			[[#FFF,Rubenwardy,Lua/UI improvements,]] ..
			[[#FFF,BuckarooBanzay,Clean-ups\, Refactoring,]] ..
			[[#FFF,Athozus,Boxes\, Maillists\, UI\, Settings,]] ..
			[[#FFF,fluxionary,Minor fixups,]] ..
			[[#FFF,SX,Various fixes\, UI,]] ..
			[[#FFF,Toby1710,UX fixes,]] ..
			[[#FFF,Peter Nerlich,CC\, BCC,]] ..
			[[#FFF,Niklp,German translation,]] ..
			[[#FFF,Emojigit,Traditional Chinese trans.,]] ..
			[[#FFF,Dennis Jenkins,UX fixes,]] ..
			[[#FFF,Thomas Rudin,Maintenance,]] ..
			[[#FFF,NatureFreshMilk,Maintenance,]] ..
			[[#FFF,imre84,UI fixes,]] ..
			[[#FFF,Chache,Spanish translation,]] ..
			[[#FFF,APercy,Brazilian Portuguese trans.,]] ..
			[[#FFF,Nuno Filipe Povoa,mail_notif.ogg,]] ..
			[[#FFF,TheTrueBeginner,Simplified Chinese trans.,]] ..
			[[#FFF,nyomi,Hungarian translation,]] ..
			[[#FFF,whosit,UI fixes]
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
