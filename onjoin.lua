minetest.register_on_joinplayer(function(player)
	minetest.after(2, function(name)
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
			minetest.chat_send_player(name,
				minetest.colorize("#00f529", "(" ..  unreadcount .. ") You have mail! Type /mail to read"))
		end
	end, player:get_player_name())
end)
