function mail.migrate()
	local gen_file_v1 = io.open(minetest.get_worldpath().."/mail.db", "r")
	if gen_file_v1 then
		mail.migrate_v1_to_v2()
	end
	
	local info_file_v3 = mail.read_json_file(mail.maildir .. "/mail.info.json")
	if not info_file_v3.dbversion then
		mail.migrate_v2_to_v3()
	end
end
	

-- migrate from mail.db to player-file-based mailbox
function mail.migrate_v1_to_v2()
	-- create directory, just in case
	minetest.mkdir(mail.maildir)
	minetest.mkdir(mail.contactsdir)

	local file = io.open(minetest.get_worldpath().."/mail.db", "r")
	if file then
		print("[mail] migrating to new per-player storage")

		local data = file:read("*a")
		local oldmails = minetest.deserialize(data)
		file:close()

		for name, oldmessages in pairs(oldmails) do
			mail.setMessages(name, oldmessages)
		end

		-- rename file
		print("[mail] migration done, renaming old mail.db")
		os.rename(minetest.get_worldpath().."/mail.db", minetest.get_worldpath().."/mail.db.old")
	end

end

-- migrate from v2 to v3 database
function mail.migrate_v2_to_v3()
	minetest.mkdir(mail.maildir) -- if necessary (eg. first login)
	minetest.log("info", "[mail] Migration from v2 to v3 database")
	minetest.after(0,function()
		for playername, value in minetest.get_auth_handler().iterate() do
			mail.migrate_contacts_v2_to_v3(playername)
		end
	end)
	mail.migrate_messages_v2_to_v3()
	local info_file = mail.read_json_file(mail.maildir .. "/mail.info.json")
	mail.write_json_file(mail.maildir .. "/mail.info.json", { dbversion = 3.0 })
end

function mail.migrate_messages_v2_to_v3()
	local already_processed = {} -- store messages that are already process to avoid duplicates
	minetest.after(0,function()
		-- check in every inbox to fetch messages
		for playername, value in minetest.get_auth_handler().iterate() do
			local saneplayername = string.gsub(playername, "[.|/]", "")
			local player_inbox = mail.read_json_file(mail.maildir .. "/" .. saneplayername .. ".json")
			for _, msg in ipairs(player_inbox) do
				local msg_id = tostring(msg.time) .. msg.sender -- id like "123456789.0singleplayer" -- it presumes that a same sender cannot send two mails within a second
				local new_msg = true -- check if that mail was already processed with another player
				for _, cur_id in ipairs(already_processed) do
					if cur_id == msg_id then
						new_msg = false
						break
					end
				end
				if new_msg then
					local msg_table = {
						sender  = msg.sender,
						to      = msg.to,
						cc      = msg.cc,
						subject = msg.subject,
						body    = msg.body,
						time    = msg.time,
					}
					mail.addMessage(msg_table)
					table.insert(already_processed, msg_id)
				end
			end
		end
	end)
end

function mail.migrate_contacts(playername)
	local gen_file_v1 = io.open(minetest.get_worldpath().."/mail.db", "r")
	if gen_file_v1 then
		mail.migrate_contacts_v1_to_v2()
	end
	
	-- v2 to v3 directly in general function
end


function mail.migrate_contacts_v1_to_v2(playername)
	local file = io.open(mail.getContactsFile(playername), 'r')
	if not file then
		-- file doesn't exist! This is a case for Migrate Man!
		local messages = mail.getMessages(playername)
		local contacts = {}

		if messages and not contacts then
			for _, message in pairs(messages) do
				mail.ensure_new_format(message)
				if contacts[string.lower(message.from)] == nil then
					contacts[string.lower(message.from)] = {
						name = message.from,
						note = "",
					}
				end
			end
		end
	else
		file:close()	-- uh, um, nope, let's leave those alone, shall we?
	end
end

function mail.migrate_contacts_v2_to_v3(playername)
	local player_contacts = mail.read_json_file(mail.maildir .. "/contacts/" .. playername .. ".json")
	
	for _, c in pairs(player_contacts) do
		mail.addContact(playername, { name = c.name, note = c.note })
	end
end
