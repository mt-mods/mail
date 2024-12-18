-- translation
local S = mail.S

core.register_on_joinplayer(function(player)
	core.after(2, function(name)
		local entry = mail.get_storage_entry(name)
		local messages = entry.inbox
		mail.hud_update(name, messages)

		local unreadcount = 0

		for _, message in pairs(messages) do
			if not message.read then
				unreadcount = unreadcount + 1
			end
		end

		if unreadcount > 0 and mail.get_setting(name, "onjoin_notifications") then
			core.chat_send_player(name,
				core.colorize(mail.get_color("new"), "(" .. unreadcount .. ") " .. S("You have mail! Type /mail to read")))
		end
	end, player:get_player_name())
end)
