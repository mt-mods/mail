local MP = minetest.get_modpath(minetest.get_current_modname())
local Channel = dofile(MP .. "/util/channel.lua")


function mail.webmail_init(http, url, key)
	mail.channel = Channel(http, url .. "/api/minetest/channel", {
		extra_headers = { "webmailkey: " .. key }
	})

	mail.channel.receive(function(data)
		if data.type == "auth" then
			mail.handlers.auth(data.data)

		elseif data.type == "send" then
			mail.handlers.send(data.data) -- { src, dst, subject, body }

		elseif data.type == "delete-mail" then
			mail.handlers.delete(data.playername, data.index) -- index 1-based

		elseif data.type == "mark-mail-read" then
			mail.handlers.mark_read(data.playername, data.index) -- index 1-based

		elseif data.type == "mark-mail-unread" then
			mail.handlers.mark_unread(data.playername, data.index) -- index 1-based

		elseif data.type == "player-messages" then
			mail.handlers.messages(data.data)

		end
	end)
end
