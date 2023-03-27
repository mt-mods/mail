
local STORAGE_VERSION_KEY = "@@version"

function mail.migrate()
	local version = mail.storage:get_int(STORAGE_VERSION_KEY)
	if version < 3 then
		mail.migrate_v2_to_v3()
		mail.storage:set_int(STORAGE_VERSION_KEY, 3)
	end
end

-- migrate from v2 to v3 database
function mail.migrate_v2_to_v3()
	minetest.mkdir(mail.maildir) -- if necessary (eg. first login)
	print("[mail] Migration from v2 to v3 database")
	local already_processed = {} -- store messages that are already process to avoid duplicates

	minetest.after(0,function()
		for playername, _ in minetest.get_auth_handler().iterate() do
			local player_contacts = mail.read_json_file(mail.maildir .. "/contacts/" .. playername .. ".json")
			local entry = mail.get_storage_entry(playername)
			for _, c in pairs(player_contacts) do
				table.insert(entry.contacts, { name = c.name, note = c.note })
			end

			local saneplayername = string.gsub(playername, "[.|/]", "")
			local player_inbox = mail.read_json_file(mail.maildir .. "/" .. saneplayername .. ".json")
			for _, msg in ipairs(player_inbox) do
				-- id like "123456789.0singleplayer" -- it presumes that a same sender cannot send two mails within a second
				local msg_id = tostring(msg.time) .. msg.sender
				local new_msg = true -- check if that mail was already processed with another player
				for _, cur_id in ipairs(already_processed) do
					if cur_id == msg_id then
						new_msg = false
						break
					end
				end
				-- add if valid and "to" field populated (missing in ancient storage formats)
				if new_msg and msg.to then
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

			mail.set_storage_entry(playername, entry)
		end
	end)
end
