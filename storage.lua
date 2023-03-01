function mail.getMailFile(playername)
	local saneplayername = string.gsub(playername, "[.|/]", "")
	return mail.maildir .. "/" .. saneplayername .. ".json"
end

function mail.getContactsFile(playername)
	local saneplayername = string.gsub(playername, "[.|/]", "")
	return mail.maildir .. "/contacts/" .. saneplayername .. ".json"
end

function mail.getMessages()
	local messages = mail.read_json_file(mail.maildir .. "/mail.messages.json")
	if messages then
		for _, msg in ipairs(messages) do
			if not msg.time then
				-- add missing time field if not available (happens with old data)
				msg.time = 0
			end
		end

		-- sort by received date descending
		table.sort(messages, function(a,b) return a.time > b.time end)
	end

	return messages
end

function mail.getPlayerMessages(playername)
	local messages = mail.getMessages()
	local playerMessages = {}
	if messages then
		for _, msg in ipairs(messages) do
			local cc = ""
			local bcc = ""
			if msg.cc then
				cc = msg.cc
			end
			if msg.bcc then
				bcc = msg.bcc
			end
			
			local receivers = mail.split((msg.to .. "," .. cc .. "," .. bcc),",") -- split players into table
			for _, receiver in ipairs(receivers) do
				receiver = string.gsub(receiver, " ", "") -- avoid blank spaces (ex : " singleplayer" instead of "singleplayer")
				if receiver == playername then -- check if player is a receiver
					if mail.getMessageStatus(receiver, msg.id) ~= "deleted" then -- do not return if the message was deleted from player
						table.insert(playerMessages, msg)
					end
				end
			end
		end
		-- show hud notification
		mail.hud_update(playername, playerMessages)
	end

	return playerMessages
end

function mail.getPlayerSentMessages(playername)
	local messages = mail.getMessages()
	local playerSentMessages = {}
	if messages[1] then
		for _, msg in ipairs(messages) do
			if msg.sender == playername then -- check if player is the sender
				if mail.getMessageStatus(playername, msg.id) ~= "deleted" then -- do not return if the message was deleted from player
					table.insert(playerSentMessages, msg)
				end
			end
		end
	end

	return playerSentMessages
end

function mail.setMessages(playername, messages)
	if mail.write_json_file(mail.getMailFile(playername), messages) then
		mail.hud_update(playername, messages)
		return true
	else
		minetest.log("error","[mail] Save failed - messages may be lost! ("..playername..")")
		return false
	end
end

function mail.addMessage(message)
	local messages = mail.getMessages()
	local message_id = 0
	if #messages > 0 then
		local previousMsg = messages[1]
		message.id = previousMsg.id + 1
	else
		message.id = 1
	end
	table.insert(messages, 1, message)
	if mail.write_json_file(mail.maildir .. "/mail.messages.json", messages) then
		-- add default status (unread for receivers) of this message
		local isSenderAReceiver = false
		local receivers = mail.split((message.to .. "," .. (message.cc or "") .. "," .. (message.bcc or "")),",")
		for _, receiver in ipairs(receivers) do
			if minetest.player_exists(receiver) then -- avoid blank names
				mail.addStatus(receiver, message.id, "unread")
				if message.sender == receiver then
					isSenderAReceiver = true
				end
			end
		end
		
		if isSenderAReceiver == false then
			mail.addStatus(message.sender, message.id, "read")
		end
		return true
	else
		minetest.log("error","[mail] Save failed - messages may be lost!")
		return false
	end
end

function mail.getStatus()
	local messagesStatus = mail.read_json_file(mail.maildir .. "/mail.status.json")
	return messagesStatus
end

function mail.getMessageStatus(player, msg_id)
	local messagesStatus = mail.getStatus()
	for _, msg in ipairs(messagesStatus) do
		if msg.id == msg_id and msg.player == player then
			return msg.status
		end
	end
end

function mail.addStatus(player, msg_id, status)
	local messagesStatus = mail.getStatus()
	local msg_status = {id = msg_id, player = player, status = status}
	table.insert(messagesStatus, 1, msg_status)
	if mail.write_json_file(mail.maildir .. "/mail.status.json", messagesStatus) then
		return true
	else
		minetest.log("error","[mail] Save failed - messages may be lost!")
		return false
	end
end

function mail.setStatus(player, msg_id, status)
	local messagesStatus = mail.getStatus()
	for _, msg_status in ipairs(messagesStatus) do
		if msg_status.id == msg_id and msg_status.player == player then
			messagesStatus[_] = {id = msg_id, player = player, status = status}
		end
	end
	if mail.write_json_file(mail.maildir .. "/mail.status.json", messagesStatus) then
		return true
	else
		minetest.log("error","[mail] Save failed - messages may be lost!")
		return false
	end
end

function mail.getContacts(playername)
	return mail.read_json_file(mail.getContactsFile(playername))
end

function mail.pairsByKeys(t, f)
	-- http://www.lua.org/pil/19.3.html
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0		-- iterator variable
	local iter = function()		-- iterator function
		i = i + 1
		if a[i] == nil then
			return nil
		else
			--return a[i], t[a[i]]
			-- add the current position and the length for convenience
			return a[i], t[a[i]], i, #a
		end
	end
	return iter
end

function mail.setContacts(playername, contacts)
	if mail.write_json_file(mail.getContactsFile(playername), contacts) then
		return true
	else
		minetest.log("error","[mail] Save failed - contacts may be lost! ("..playername..")")
		return false
	end
end


function mail.read_json_file(path)
	local file = io.open(path, "r")
	local content = {}
	if file then
		local json = file:read("*a")
		content = minetest.parse_json(json or "[]") or {}
		file:close()
	end
	return content
end

function mail.write_json_file(path, content)
	local file = io.open(path,"w")
	local json = minetest.write_json(content)
	if file and file:write(json) and file:close() then
		return true
	else
		return false
	end
end
