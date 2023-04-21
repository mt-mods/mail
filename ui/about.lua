local FORMNAME = "mail:about"

function mail.show_about(name)
	local formspec = [[
			size[10,6;]
			button[9.35,0;0.75,0.5;back;X]
			label[0,0;Mail]
			label[0,0.4;Provided my mt-mods]
			label[0,0.8;Version: 1.1.3]
			label[0,1.4;Licenses:]
			label[0.2,1.8;Expat (code), WTFPL (textures)]
			label[0,2.4;https://github.com/mt-mods/mail]
			label[0,2.8;https://content.minetest.net/packages/mt-mods/mail]
			textarea[0.5,4.0;4,5.5;;Note;]] ..
			[[NOTE: Communication using this system is NOT guaranteed to be private!]] ..
			[[ Admins are able to view the messages of any player.]

			tablecolumns[color;text;text]
			table[5,0.75;4.9,5.5;contributors;]] ..
			[[#999,Contributors,,]] ..
			[[#FFD700,Cheapie,Initial idea/project,]] ..
			[[#FFF,Rubenwardy,Lua/UI improvements,]] ..
			[[#FFF,BuckarooBanzay,Clean-ups\, Refactoring,]] ..
			[[#FFF,Athozus,Outbox\, Maillists\, UI\, Drafts,]] ..
			[[#FFF,fluxionary,Minor fixups,]] ..
			[[#FFF,SX,Various fixes\, UI,]] ..
			[[#FFF,Toby1710,UX fixes,]] ..
			[[#FFF,Peter Nerlich,CC\, BCC,]] ..
			[[#FFF,Niklp,German translation,]] ..
			[[#FFF,Emojigit,Chinese translation,]] ..
			[[#FFF,Dennis Jenkins,UX fixes,]] ..
			[[#FFF,Thomas Rudin,Maintenance,]] ..
			[[#FFF,NatureFreshMilk,Maintenance]
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
