local STORAGE_VERSION_KEY = "@@version"
local CURRENT_VERSION = 3.1

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



local function search_box(playername, box, uuid)
	local e = mail.get_storage_entry(playername)
	for _, m in ipairs(e[box]) do
		if m.id == uuid then
		return { time = m.time, from = m.from, to = m.to, cc = m.cc, bcc = m.bcc, subject = m.subject, body = m.body } end
	end
	return false
end

local function search_boxes(playername, boxes, uuid)
	local result
	for _, b in ipairs(boxes) do
		result = search_box(playername, b, uuid)
		if result then return result end
	end
end

local function is_uuid_existing(uuid)
	local boxes = {"inbox", "outbox", "drafts", "trash"}
	if mail.storage.get_keys then
		for _, k in ipairs(mail.storage:get_keys()) do
			if string.sub(k,1,5) == "mail/" then
				local p = string.sub(k, 6)
				local result = search_boxes(p, boxes, uuid)
				if result then return result end
			end
		end
	else
		for p, _ in minetest.get_auth_handler().iterate() do
			local result = search_boxes(p, boxes, uuid)
			if result then return result end
		end
    end
    return false
end

local function are_message_sames(a, b)
	return a.time == b.time
	   and a.from == b.from
	   and a.to == b.to
	   and a.cc == b.cc
	   and a.bcc == b.bcc
	   and a.subject == b.subject
	   and a.body == b.body
end

local function replace_other_player_message_uuid(p, m, uuid, new_uuid)
	local er = mail.get_storage_entry(p)
	for _, r in ipairs(er.inbox) do
		if r.id == uuid and not are_message_sames(m, r) then
			r.id = new_uuid
		end
	end
	for _, r in ipairs(er.outbox) do
		if r.id == uuid and not are_message_sames(m, r) then
			r.id = new_uuid
		end
	end
	for _, r in ipairs(er.drafts) do
		if r.id == uuid and not are_message_sames(m, r) then
			r.id = new_uuid
		end
	end
	for _, r in ipairs(er.trash) do
		if r.id == uuid and not are_message_sames(m, r) then
			r.id = new_uuid
		end
	end
	mail.set_storage_entry(p, er)
end

local function fix_box_duplicate_uuids(playername, box)
	local e = mail.get_storage_entry(playername)
	for _, m in ipairs(e[box]) do
		local uuid = m.id
		local exists = is_uuid_existing(uuid)
		if exists and not are_message_sames(exists, m) then
			local new_uuid = mail.new_uuid() -- generates a new uuid to replace doublons
			if mail.storage.get_keys then
				for _, k in ipairs(mail.storage:get_keys()) do
					if string.sub(k,1,5) == "mail/" then
						local p = string.sub(k, 6)
						replace_other_player_message_uuid(p, m, uuid, new_uuid)
					end
				end
			else
				for p, _ in minetest.get_auth_handler().iterate() do
					replace_other_player_message_uuid(p, m, uuid, new_uuid)
				end
			end
		end
	end
end

local function fix_player_duplicate_uuids(playername)
	fix_box_duplicate_uuids(playername, "inbox")
	fix_box_duplicate_uuids(playername, "outbox")
	fix_box_duplicate_uuids(playername, "drafts")
	fix_box_duplicate_uuids(playername, "trash")
end

-- repair database for uuid doublons
local function repair_storage()
	-- iterate through players
	-- get_keys() was introduced in 5.7
	if mail.storage.get_keys then
		for _, k in ipairs(mail.storage:get_keys()) do
			if string.sub(k,1,5) == "mail/" then
				local p = string.sub(k, 6)
				fix_player_duplicate_uuids(p)
			end
		end
	else
		minetest.after(0, function()
			for p, _ in minetest.get_auth_handler().iterate() do
				fix_player_duplicate_uuids(p)
			end
		end)
	end
end

function mail.migrate()
	-- check for v2 storage first, v1-migration might have set the v3-flag already
	local version = mail.storage:get_float(STORAGE_VERSION_KEY)
	if version < math.floor(CURRENT_VERSION) then
		-- v2 to v3
		migrate_v2_to_v3()
		mail.storage:set_float(STORAGE_VERSION_KEY, CURRENT_VERSION)
	end

	-- check for v1 storage
	local v1_file = io.open(minetest.get_worldpath().."/mail.db", "r")
	if v1_file then
		-- v1 to v3
		migrate_v1_to_v3()
		mail.storage:set_float(STORAGE_VERSION_KEY, CURRENT_VERSION)
	end

	-- repair storage for uuid doublons
	if version < CURRENT_VERSION  then
		repair_storage()
		mail.storage:set_float(STORAGE_VERSION_KEY, CURRENT_VERSION)
	end
end
