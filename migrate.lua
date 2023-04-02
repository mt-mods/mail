
local STORAGE_VERSION_KEY = "@@version"

local function migrate_v1_to_v3()
	local file = io.open(minetest.get_worldpath().."/mail.db", "r")
	assert(file)
	print("[mail] Migration from v1 to v3 database")

	local data = file:read("*a")
	local oldmails = minetest.deserialize(data)
	file:close()

	for name, oldmessages in pairs(oldmails) do
		print("[mail,v1] + migrating player '" .. name .. "'")
		local entry = mail.get_storage_entry(name)
		for _, msg in ipairs(oldmessages) do
			table.insert(entry.inbox, {
				id = mail.new_uuid(),
				from  = msg.sender or msg.from,
				to      = msg.to or name,
				subject = msg.subject,
				body    = msg.body,
				time    = msg.time or os.time(),
			})
		end
		mail.set_storage_entry(name, entry)
	end

	-- rename file
	print("[mail,v1] migration done, renaming old mail.db")
	os.rename(minetest.get_worldpath().."/mail.db", minetest.get_worldpath().."/mail.db.old")
end

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

-- migrate from v2 to v3 database
local function migrate_v2_to_v3()
	local maildir = minetest.get_worldpath().."/mails"
	minetest.mkdir(maildir) -- if necessary (eg. first login)
	print("[mail] Migration from v2 to v3 database")

	-- defer execution until auth-handler ready (first server-step)
	minetest.after(0, function()
		for playername, _ in minetest.get_auth_handler().iterate() do
			local entry = mail.get_storage_entry(playername)

			local player_contacts = read_json_file(maildir .. "/contacts/" .. playername .. ".json")
			for _, c in pairs(player_contacts) do
				table.insert(entry.contacts, { name = c.name, note = c.note })
			end

			local saneplayername = string.gsub(playername, "[.|/]", "")
			local player_inbox = read_json_file(maildir .. "/" .. saneplayername .. ".json")
			print("[mail,v2] + migrating player '" .. playername .. "'")
			for _, msg in ipairs(player_inbox) do
				table.insert(entry.inbox, {
                                        id = mail.new_uuid(),
                                        from  = msg.sender or msg.from,
                                        to      = msg.to or playername,
                                        cc      = msg.cc,
                                        subject = msg.subject,
                                        body    = msg.body,
                                        time    = msg.time or os.time(),
					read    = not msg.unread,
				})
			end

			mail.set_storage_entry(playername, entry)
		end
		print("[mail,v2] migration done")
	end)
end

function mail.migrate()
	-- check for v2 storage first, v1-migration might have set the v3-flag already
	local version = mail.storage:get_int(STORAGE_VERSION_KEY)
	if version < 3 then
		-- v2 to v3
		migrate_v2_to_v3()
		mail.storage:set_int(STORAGE_VERSION_KEY, 3)
	end

	-- check for v1 storage
	local v1_file = io.open(minetest.get_worldpath().."/mail.db", "r")
	if v1_file then
		-- v1 to v3
		migrate_v1_to_v3()
		mail.storage:set_int(STORAGE_VERSION_KEY, 3)
	end
end
