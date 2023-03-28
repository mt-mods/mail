
local STORAGE_VERSION_KEY = "@@version"

local function read_json_file(path)
	local file = io.open(path, "r")
	local content = {}
	if file then
		local json = file:read("*a")
		content = minetest.parse_json(json or "[]") or {}
		file:close()
	end
	return content
end


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

	minetest.after(0,function()
		for playername, _ in minetest.get_auth_handler().iterate() do
			local entry = mail.get_storage_entry(playername)

			local player_contacts = read_json_file(mail.maildir .. "/contacts/" .. playername .. ".json")
			for _, c in pairs(player_contacts) do
				table.insert(entry.contacts, { name = c.name, note = c.note })
			end

			local saneplayername = string.gsub(playername, "[.|/]", "")
			local player_inbox = read_json_file(mail.maildir .. "/" .. saneplayername .. ".json")
			for _, msg in ipairs(player_inbox) do
				if msg.to then
					table.insert(entry.inbox, {
						id = mail.new_uuid(),
						from  = msg.sender or msg.from,
						to      = msg.to,
						cc      = msg.cc,
						subject = msg.subject,
						body    = msg.body,
						time    = msg.time,
					})
				end
			end

			mail.set_storage_entry(playername, entry)
		end
	end)
end
