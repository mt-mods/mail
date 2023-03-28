function mail.get_storage_entry(playername)
	local str = mail.storage:get_string(playername)
	if str == "" then
		-- new entry
		return {
			contacts = {},
			inbox = {},
			outbox = {},
			lists = {}
		}
	else
		-- deserialize existing entry
		return minetest.parse_json(str)
	end
end

--[[
Mail format (inbox, outbox):
{
	-- sending player name
	sender = "",
	-- receiving player name
	to = "",
	-- carbon copy (optional)
	cc = "",
	-- blind carbon copy (optional)
	bcc = "",
	-- mail subject
	subject = "",
	-- mail body
	body = "",
	-- timestamp (os.time())
	time = 1234,
	-- read-flag (true: player has read the mail, inbox only)
	read = true
}

Contact format:
{
	-- name of the player
	name = "",
	-- note
	note = ""
}

Mail-list format:
{
	-- name of the maillist
	name = "",
	-- description
	description = "",
	-- player list (delimited by newline)
	players = ""
}

--]]

function mail.set_storage_entry(playername, entry)
	mail.storage:get_string(playername, minetest.write_json(entry))
end

-- get a mail by id from the players in- or outbox
function mail.get_message(playername, msg_id)
	local entry = mail.get_storage_entry(playername)
	for _, msg in ipairs(entry.inbox) do
		if msg.id == msg_id then
			return msg
		end
	end
	for _, msg in ipairs(entry.outbox) do
		if msg.id == msg_id then
			return msg
		end
	end
end

-- marks a mail read by its id
function mail.mark_read(playername, msg_id)
	local entry = mail.get_storage_entry(playername)
	for _, msg in ipairs(entry.inbox) do
		if msg.id == msg_id then
			msg.read = true
			mail.set_storage_entry(playername, entry)
			return
		end
	end
end

-- marks a mail unread by its id
function mail.mark_unread(playername, msg_id)
	local entry = mail.get_storage_entry(playername)
	for _, msg in ipairs(entry.inbox) do
		if msg.id == msg_id then
			msg.read = false
			mail.set_storage_entry(playername, entry)
			return
		end
	end
end

-- deletes a mail by its id
function mail.delete_mail(playername, msg_id)
	local entry = mail.get_storage_entry(playername)
	for i, msg in ipairs(entry.inbox) do
		if msg.id == msg_id then
			table.remove(entry.outbox, i)
			mail.set_storage_entry(playername, entry)
			return
		end
	end
	for i, msg in ipairs(entry.outbox) do
		if msg.id == msg_id then
			table.remove(entry.outbox, i)
			mail.set_storage_entry(playername, entry)
			return
		end
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
	table.insert(maillists, maillist)
	if mail.write_json_file(mail.maildir .. "/mail.maillists.json", maillists) then
		-- add status for players contained in the maillist
		local players = mail.parse_player_list(players_string)
		for _, player in ipairs(players) do
			if minetest.player_exists(player) then -- avoid blank names
				mail.addPlayerToMaillist(player, maillist.id)
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
			maillists[_] = {
				id = maillist_id,
				owner = updated_maillist.owner,
				name = updated_maillist.name,
				desc = updated_maillist.desc}
		end
	end
	if mail.write_json_file(mail.maildir .. "/mail.maillists.json", maillists) then
		-- remove all players
		mail.removePlayersFromMaillist(maillist_id)
		-- to add those registered in the updated maillist
		local players = mail.parse_player_list(players_string)
		for _, player in ipairs(players) do
			if minetest.player_exists(player) then -- avoid blank names
				mail.addPlayerToMaillist(player, maillist_id)
			end
		end
		return true
	else
		minetest.log("error","[mail] Save failed - maillist may be lost!")
		return false
	end
end

function mail.getMaillistIdFromName(ml_name, owner)
	local maillists = mail.getMaillists()
	local ml_id = 0
	for _, maillist in ipairs(maillists) do
		if maillist.name == ml_name and maillist.owner == owner then
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
				table.insert(players_ml, playerInfo)
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
			if playerInfo and playerInfo.player and minetest.player_exists(playerInfo.player) then
				table.insert(players_names_ml, playerInfo.player)
			end
		end
	end
	return players_names_ml
end

function mail.addPlayerToMaillist(player, ml_id)
	local playersMls = mail.getPlayersInMaillists()
	local new_player = {id = ml_id, player = player}
	table.insert(playersMls, new_player)
	if mail.write_json_file(mail.maildir .. "/mail.maillists_players.json", playersMls) then
		return true
	else
		minetest.log("error","[mail] Save failed - maillist may be lost!")
		return false
	end
end

function mail.removePlayersFromMaillist(ml_id)
	local maillists_players = mail.getPlayersInMaillists()
	for i=#maillists_players,1,-1 do
		local playerInfo = maillists_players[i]
		if playerInfo.id == ml_id then
			table.remove(maillists_players, i)
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
	-- remove players attached to the maillist
	local players_writing_done = mail.removePlayersFromMaillist(ml_id)
	-- then remove the maillist itself
	for _, maillist in ipairs(maillists) do
		if maillist.id == ml_id then
			table.remove(maillists, _)
		end
	end
	local maillist_writing_done = mail.write_json_file(mail.maildir .. "/mail.maillists.json", maillists)
	if players_writing_done and maillist_writing_done then
		return true
	else
		minetest.log("error","[mail] Save failed!")
		return false
	end
end

function mail.extractMaillists(receivers_string, maillists_owner)
	local globalReceivers = mail.parse_player_list(receivers_string) -- receivers including maillists
	local receivers = {} -- extracted receivers

	-- extract players from mailing lists
	for _, receiver in ipairs(globalReceivers) do
		local receiverInfo = receiver:split("@") -- @maillist
		if receiverInfo[1] and receiver == "@" .. receiverInfo[1]
			and mail.getMaillistIdFromName(receiverInfo[1], maillists_owner) ~= 0 then -- in case of maillist
			local players_ml = mail.getPlayersInMaillist(mail.getMaillistIdFromName(receiverInfo[1], maillists_owner))
			if players_ml then
				for _, player in ipairs(players_ml) do
					table.insert(receivers, player)
				end
			end
		else -- in case of player
			table.insert(receivers, receiver)
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
	for i=#contacts,1,-1 do
		local contact = contacts[i]
		if contact.owner == owner and contact.name == name then
			table.remove(contacts, i)
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
