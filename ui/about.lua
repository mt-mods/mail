local FORMNAME = "mail:about"

function mail.show_about(name)
	local formspec = [[
			size[8,5;]
			button[7.25,0;0.75,0.5;back;X]
			label[0,0;Mail]
			label[0,0.5;By cheapie]
			label[0,1;http://github.com/cheapie/mail]
			label[0,1.5;See LICENSE file for license information]
			label[0,2.5;NOTE: Communication using this system]
			label[0,3;is NOT guaranteed to be private!]
			label[0,3.5;Admins are able to view the messages]
			label[0,4;of any player.]
		]] .. mail.theme

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname)
	if formname ~= FORMNAME then
		return
	end

	local playername = player:get_player_name()
	mail.show_mail_menu(playername)
end)