function mail.getMailFile(playername)
	local saneplayername = string.gsub(playername, "[.|/]", "")
	return mail.maildir .. "/" .. saneplayername .. ".json"
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

function mail.getMessage(msg_id)
	local messages = mail.getMessages()
	if messages then
		for _, msg in ipairs(messages) do
			if msg.id == msg_id then
				return msg
			end
		end
	end
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
			local receivers = mail.extractMaillists((msg.to .. "," .. (msg.cc or "") .. "," .. (msg.bcc or "")),",") -- extracted maillists from all receivers
			for _, receiver in ipairs(receivers) do
				receiver = string.gsub(receiver, " ", "") -- avoid blank spaces (ex : " singleplayer" instead of "singleplayer")
				if receiver == playername then -- check if player is a receiver
					if mail.getMessageStatus(receiver, msg.id) ~= "deleted" then -- do not return if the message was deleted from player
						table.insert(playerMessages, msg)
						break
					end
				elseif msg.sender == playername then
					if mail.getMessageStatus(receiver, msg.id) ~= "deleted" then -- do not return if the message was deleted from player
						table.insert(playerMessages, msg)
						break
					end
				end
			end
		end
	end

	return playerMessages
end

function mail.getPlayerInboxMessages(playername)
	local messages = mail.getMessages()
	local playerInboxMessages = {}
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
			local receivers = mail.extractMaillists((msg.to .. "," .. (msg.cc or "") .. "," .. (msg.bcc or "")),",") -- extracted maillists from all receivers
			for _, receiver in ipairs(receivers) do
				receiver = string.gsub(receiver, " ", "") -- avoid blank spaces (ex : " singleplayer" instead of "singleplayer")
				if receiver == playername then -- check if player is a receiver
					if mail.getMessageStatus(receiver, msg.id) ~= "deleted" then -- do not return if the message was deleted from player
						table.insert(playerInboxMessages, msg)
						break
					end
				end
			end
		end
		-- show hud notification
		mail.hud_update(playername, playerInboxMessages)
	end

	return playerInboxMessages
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
	if messages[1] then
		local previousMsg = messages[1]
		message.id = previousMsg.id + 1
	else
		message.id = 1
	end
	table.insert(messages, 1, message)
	if mail.write_json_file(mail.maildir .. "/mail.messages.json", messages) then
		-- add default status (unread for receivers) of this message
		local isSenderAReceiver = false
		
		local receivers = mail.extractMaillists((message.to .. "," .. (message.cc or "") .. "," .. (message.bcc or "")),",") -- extracted maillists from all receivers
		
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
		minetest.log("error","[mail] Save failed - messages status may be lost!")
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
		minetest.log("error","[mail] Save failed - messages status may be lost!")
		return false
	end
end

function mail.getContactsFile()
	return mail.maildir .. "/mail.contacts.json"
end

function mail.getContacts()
	local contacts = mail.read_json_file(mail.maildir .. "/mail.contacts.json")
	return contacts
end

function mail.getPlayerContacts(playername)
	local contacts = mail.getContacts()
	local playerContacts = {}
	for _, contact in ipairs(contacts) do
		if contact.owner == playername then
			table.insert(playerContacts, {name = contact.name, note = contact.note})
		end
	end
	return playerContacts
end

function mail.getMaillists()
	local maillists = mail.read_json_file(mail.maildir .. "/mail.maillists.json")
	return maillists
end

function mail.getPlayerMaillists(playername)
	local maillists = mail.getMaillists()
	local playerMaillists = {}
	for _, maillist in ipairs(maillists) do
		if maillist.owner == playername then
			table.insert(playerMaillists, {id = maillist.id, name = maillist.name, desc = maillist.desc})
		end
	end
	return playerMaillists
end

function mail.addMaillist(maillist, players_string)
	local maillists = mail.getMaillists()
	if maillists[1] then
		local previousMl = maillists[1]
		maillist.id = previousMl.id + 1
	else
		maillist.id = 1
	end
	table.insert(maillists, 1, maillist)
	if mail.write_json_file(mail.maildir .. "/mail.maillists.json", maillists) then
		-- add status for players contained in the maillist
		local players = mail.split(players_string,"\n")
		for _, player in ipairs(players) do
			local playerInfo = mail.split(player, " ")
			if minetest.player_exists(playerInfo[1]) then -- avoid blank names
				mail.addPlayerToMaillist(playerInfo[1], maillist.id, playerInfo[2])
			end
		end
		return true
	else
		minetest.log("error","[mail] Save failed - maillist may be lost!")
		return false
	end
end

function mail.setMaillist(ml_id, updated_maillist, players_string)
	local maillists = mail.getMaillists()
	local maillist_id = 0
	for _, maillist in ipairs(maillists) do
		if maillist.id == ml_id then
			maillist_id = maillist.id
			maillists[_] = {id = maillist_id, owner = updated_maillist.owner, name = updated_maillist.name, desc = updated_maillist.desc}
		end
	end
	if mail.write_json_file(mail.maildir .. "/mail.maillists.json", maillists) then
		-- remove all players
		mail.removePlayersFromMaillist(maillist_id)
		-- to add those registered in the updated maillist
		local players = mail.split(players_string,"\n")
		for _, player in ipairs(players) do
			local playerInfo = mail.split(player, " ")
			if minetest.player_exists(playerInfo[1]) then -- avoid blank names
				mail.addPlayerToMaillist(playerInfo[1], maillist_id, playerInfo[2])
			end
		end
		return true
	else
		minetest.log("error","[mail] Save failed - maillist may be lost!")
		return false
	end
end

function mail.getMaillistIdFromName(ml_name)
	local maillists = mail.getMaillists()
	local ml_id = 0
	for _, maillist in ipairs(maillists) do
		if maillist.name == ml_name then
			ml_id = maillist.id
			break
		end
	end
	return ml_id
end

function mail.getPlayersInMaillists()
	local players_mls = mail.read_json_file(mail.maildir .. "/mail.maillists_players.json")
	return players_mls
end

function mail.getPlayersDataInMaillist(ml_id)
	local players_mls = mail.getPlayersInMaillists() -- players from all maillists
	local players_ml = {} -- players from this maillist
	if players_mls[1] then
		for _, playerInfo in ipairs(players_mls) do
			if playerInfo.id == ml_id then
				table.insert(players_ml, 1, playerInfo)
			end
		end
	end
	return players_ml
end

function mail.getPlayersInMaillist(ml_id)
	local players_ml = mail.getPlayersDataInMaillist(ml_id) -- players from this maillist
	local players_names_ml = {}
	if players_ml[1] then
		for _, playerInfo in ipairs(players_ml) do
			table.insert(players_names_ml, 1, playerInfo.player)
		end
	end
	return players_names_ml
end

function mail.addPlayerToMaillist(player, ml_id, status)
	local playersMls = mail.getPlayersInMaillists()
	local new_player = {id = ml_id, player = player, status = status}
	table.insert(playersMls, 1, new_player)
	if mail.write_json_file(mail.maildir .. "/mail.maillists_players.json", playersMls) then
		return true
	else
		minetest.log("error","[mail] Save failed - maillist may be lost!")
		return false
	end
end

function mail.setPlayerInMaillist(playername, ml_id, status)
	local playersMls = mail.getPlayersInMaillists()
	local updated_player = {id = ml_id, player = player, status = status}
	table.insert(playersMls, 1, new_player)
	for _, player in ipairs(playersMls) do
		if player.player == playername and player.id == ml_id then
			playersMls[_] = {id = ml_id, player = player, status = status}
		end
	end
	if mail.write_json_file(mail.maildir .. "/mail.maillists_players.json", playersMls) then
		return true
	else
		minetest.log("error","[mail] Save failed - maillist may be lost!")
		return false
	end
end

function mail.removePlayersFromMaillist(ml_id)
	local maillists_players = mail.getPlayersInMaillists()
	for _, player in ipairs(maillists_players) do
		if player.id == ml_id then
			table.remove(maillists_players, _)
		end
	end
	if mail.write_json_file(mail.maildir .. "/mail.maillists_players.json", maillists_players) then
		return true
	else
		minetest.log("error","[mail] Save failed!")
		return false
	end
end

function mail.deleteMaillist(ml_id)
	local maillists = mail.getMaillists()
	local maillists_players = mail.getPlayersInMaillists()
	-- remove players attached to the maillist
	for _, player in ipairs(maillists_players) do
		if player.id == ml_id then
			table.remove(maillists_players, _)
		end
	end
	-- then remove the maillist itself
	for _, maillist in ipairs(maillists) do
		if maillist.id == ml_id then
			table.remove(maillists, _)
		end
	end
	if mail.write_json_file(mail.maildir .. "/mail.maillists_players.json", maillists_players) and mail.write_json_file(mail.maildir .. "/mail.maillists.json", maillists) then
		return true
	else
		minetest.log("error","[mail] Save failed!")
		return false
	end
end

function mail.extractMaillists(receivers)
	local globalReceivers = mail.split(receivers,",") -- receivers including maillists
	local receivers = {} -- extracted receivers
	
	-- extract players from mailing lists
	for _, receiver in ipairs(globalReceivers) do
		local receiverInfo = mail.split(receiver, "@") -- @maillist
		if receiverInfo[1] == "" and receiverInfo[2] then -- in case of maillist
			local players_ml = mail.getPlayersInMaillist(mail.getMaillistIdFromName(receiverInfo[2]))
			if players_ml then
				for _, player in ipairs(players_ml) do
					table.insert(receivers, 1, player)
				end
			end
		else -- in case of player
			table.insert(receivers, 1, receiver)
		end
	end
	
	return receivers
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

function mail.addContact(playername, contact)
	local contacts = mail.getContacts()
	local newContact = {owner = playername, name = contact.name, note = contact.note}
	table.insert(contacts, 1, newContact)
	if mail.write_json_file(mail.maildir .. "/mail.contacts.json", contacts) then
		return true
	else
		minetest.log("error","[mail] Save failed - contact may be lost!")
		return false
	end
end

function mail.setContact(playername, updated_contact)
	local contacts = mail.getContacts()
	for _, contact in ipairs(contacts) do
		if contact.owner == playername and contact.name == updated_contact.name then
			contacts[_] = {owner = playername, name = updated_contact.name, note = updated_contact.note}
		end
	end
	if mail.write_json_file(mail.maildir .. "/mail.contacts.json", contacts) then
		return true
	else
		minetest.log("error","[mail] Save failed - contact may be lost!")
		return false
	end
end

function mail.deleteContact(owner, name)
	local contacts = mail.getContacts()
	for _, contact in ipairs(contacts) do
		if contact.owner == owner and contact.name == name then
			table.remove(contacts, _)
		end
	end
	if mail.write_json_file(mail.maildir .. "/mail.contacts.json", contacts) then
		return true
	else
		minetest.log("error","[mail] Save failed - contact may be lost!")
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
