-- false per default
local has_xban2_mod = minetest.get_modpath("xban2")

local MP = minetest.get_modpath(minetest.get_current_modname())
local Channel = dofile(MP .. "/util/channel.lua")
local channel

-- auth request from webmail
local function auth_handler(auth)
	local handler = minetest.get_auth_handler()
	minetest.log("action", "[webmail] auth: " .. auth.name)

	local success = false
	local banned = false
	local message = ""

	if mail.webmail.disallow_banned_players and has_xban2_mod then
		-- check xban db
		local xbanentry = xban.find_entry(auth.name)
		if xbanentry and xbanentry.banned then
			banned = true
			message = "Banned!"
		end
	end

	if not banned then
		-- check tan
		local tan = mail.tan[auth.name]
		if tan ~= nil then
			success = tan == auth.password
		end

		-- check auth
		if not success then
			local entry = handler.get_auth(auth.name)
			if entry and minetest.check_password_entry(auth.name, entry.password, auth.password) then
				success = true
			end
		end
	end

	channel.send({
		type = "auth",
		data = {
			name = auth.name,
			success = success,
			message = message
		}
	})
end

-- send request from webmail
local function send_handler(sendmail)
	-- send mail from webclient
	minetest.log("action", "[webmail] sending mail from webclient: " .. sendmail.src .. " -> " .. sendmail.dst)
	mail.send(sendmail)
end

-- get player messages request from webmail
local function get_player_messages_handler(playername)
	local messages = mail.getMessages(playername)
	channel.send({
		type = "player-messages",
		playername = playername,
		data = messages
	})
end

-- remove mail
local function delete_mail_handler(playername, index)
	local messages = mail.getMessages(playername)
	if messages[index] then
		table.remove(messages, index)
	end
	mail.setMessages(playername, messages)
end

-- mark mail as read
local function mark_mail_read_handler(playername, index)
	local messages = mail.getMessages(playername)
	if messages[index] then
		messages[index].unread = false
	end
	mail.setMessages(playername, messages)
end

-- mark mail as unread
local function mark_mail_unread_handler(playername, index)
	local messages = mail.getMessages(playername)
	if messages[index] then
		messages[index].unread = true
	end
	mail.setMessages(playername, messages)
end

function mail.webmail_send_hook(m)
	channel.send({
		type = "new-message",
		data = m
	})
end
mail.register_on_receive(mail.webmail_send_hook)

function mail.webmail_init(http, url, key)
	channel = Channel(http, url .. "/api/minetest/channel", {
		extra_headers = { "webmailkey: " .. key }
	})

	channel.receive(function(data)
		if data.type == "auth" then
			auth_handler(data.data)

		elseif data.type == "send" then
			send_handler(data.data) -- { src, dst, subject, body }

		elseif data.type == "delete-mail" then
			delete_mail_handler(data.playername, data.index) -- index 1-based

		elseif data.type == "mark-mail-read" then
			mark_mail_read_handler(data.playername, data.index) -- index 1-based

		elseif data.type == "mark-mail-unread" then
			mark_mail_unread_handler(data.playername, data.index) -- index 1-based

		elseif data.type == "player-messages" then
			get_player_messages_handler(data.data)

		end
	end)
end
