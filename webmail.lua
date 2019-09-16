-- false per default
local has_xban2_mod = minetest.get_modpath("xban2")

local MP = minetest.get_modpath(minetest.get_current_modname())
local Channel = dofile(MP .. "/util/channel.lua")
local channel

-- auth request from webmail
local function auth_handler(data)
	local auth = data.params
	local handler = minetest.get_auth_handler()
	minetest.log("action", "[webmail] auth: " .. auth.playername)

	local success = false
	local banned = false
	local message = ""

	if mail.webmail.disallow_banned_players and has_xban2_mod then
		-- check xban db
		local xbanentry = xban.find_entry(auth.playername)
		if xbanentry and xbanentry.banned then
			banned = true
			message = "Banned!"
		end
	end

	if not banned then
		-- check tan
		local tan = mail.tan[auth.playername]
		if tan ~= nil then
			success = tan == auth.password
		end

		-- check auth
		if not success then
			local entry = handler.get_auth(auth.playername)
			if entry and minetest.check_password_entry(auth.playername, entry.password, auth.password) then
				success = true
			end
		end
	end

	channel.send({
		method = data.method,
		id = data.id,
		result = {
			success = success,
			message = message
		}
	})
end

-- send request from webmail
local function send_handler(data)
	-- send mail from webclient
	if not data.params then
		return
	end

	minetest.log("action", "[webmail] sending mail from webclient: " .. data.params.sender ..
		" -> " .. data.params.receiver)

	mail.send(data.params)

	channel.send({
		method = data.method,
		id = data.id,
		result = {
			success = true
		}
	})
end

-- get player messages request from webmail
local function get_player_messages_handler(data)
	local messages = mail.getMessages(data.params.playername)
	channel.send({
		method = data.method,
		id = data.id,
		result = messages
	})
end

-- remove mail
local function delete_mail_handler(data)
	local index = data.params.index
	local playername = data.params.playername

	local messages = mail.getMessages(playername)
	if messages[index] then
		table.remove(messages, index)
	end
	mail.setMessages(playername, messages)
	-- TODO: check subject

	channel.send({
		method = data.method,
		id = data.id,
		result = { success = true }
	})
end

-- mark mail as read
local function mark_mail_read_handler(data)
	local index = data.params.index
	local playername = data.params.playername
	local read = data.params.read

	local messages = mail.getMessages(playername)

	if messages[index] then
		messages[index].unread = not read
	end
	mail.setMessages(playername, messages)
	-- TODO: check subject

	channel.send({
		method = data.method,
		id = data.id,
		result = { success = true }
	})
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
		if data.method == "auth" then
			auth_handler(data)

		elseif data.method == "get-mails" then
			get_player_messages_handler(data)

		elseif data.method == "mark-mail-read" then
			mark_mail_read_handler(data)

		elseif data.method == "delete-mail" then
			delete_mail_handler(data)

		elseif data.method == "send" then
			send_handler(data)


		end
	end)
end
