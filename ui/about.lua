local FORMNAME = "mail:about"

function mail.show_about(name)
	local formspec = [[
			size[10,6;]
			button[9.35,0;0.75,0.5;back;X]
			label[0,0;Mail]
			label[0,0.4;Provided my mt-mods]
			label[5,0;Version: 1.0.3]
			label[0,1.0;License : WTFPL for textures]
			label[0,1.4;https://github.com/mt-mods/mail]
			label[0,1.8;https://content.minetest.net/packages/mt-mods/mail]
			textarea[0.5,3.5;4,5.5;;Note;]] ..
			[[NOTE: Communication using this system is NOT guaranteed to be private!]] ..
			[[ Admins are able to view the messages of any player.]

			tablecolumns[color;text;text]
			table[5,0.75;4.9,5.5;contributors;]] ..
			[[#999,Contributors,,]] ..
			[[#FFD700,Cheapie,Initial idea/project,]] ..
			[[#FFF,Rubenwardy,Lua/UI improvements,]] ..
			[[#FFF,BuckarooBanzay,Clean-ups\, Refactoring,]] ..
			[[#FFF,Athozus,Outbox\, Maillists\, UI fixes,]] ..
			[[#FFF,fluxionary,Minor fixups,]] ..
			[[#FFF,SX,Various fixes,]] ..
			[[#FFF,Toby1710,Ux fixes,]] ..
			[[#FFF,Peter Nerlich,CC\, BCC]
		]] .. mail.theme

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	if fields.back then
		local playername = player:get_player_name()
		mail.show_mail_menu(playername)
	end
end)
