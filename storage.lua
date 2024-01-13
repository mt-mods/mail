-- storage getter/setter
local STORAGE_PREFIX = "mail/"

-- create or populate empty fields on an entry
local function populate_entry(e)
	e = e or {}
	e.contacts = e.contacts or {}
	e.inbox = e.inbox or {}
	e.outbox = e.outbox or {}
	e.drafts = e.drafts or {}
	e.trash = e.trash or {}
	e.lists = e.lists or {}
	e.settings = e.settings or {}
	return e
end

local cache = {}

-- retrieve the storage entry for the player
function mail.get_storage_entry(playername)
	local key = STORAGE_PREFIX .. playername
	if cache[key] then
		-- use cached entry
		return cache[key]
	end

	local str = mail.storage:get_string(key)
	local entry
	if str == "" then
		-- new entry
		entry = populate_entry()
	else
		-- deserialize existing entry
		local e = minetest.parse_json(str)
		entry = populate_entry(e)
	end

	-- cache for next time
	cache[key] = entry
	return entry
end

-- entries queued for saving
local save_queued_entries = {}

-- save the storage entry for the player
function mail.set_storage_entry(playername, entry)
	local key = STORAGE_PREFIX .. playername
	-- cache
	cache[key] = entry
	-- enqueue for writing
	save_queued_entries[key] = entry
end

local function save_worker()
	for key, entry in pairs(save_queued_entries) do
		-- write to backend
		mail.storage:set_string(key, minetest.write_json(entry))
	end

	-- clear queue
	save_queued_entries = {}

	-- clear cached entries
	cache = {}

	-- save every second
	minetest.after(1, save_worker)
end

-- start save-worker loop
save_worker()
-- save on shutdown
minetest.register_on_shutdown(save_worker)

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
	for _, msg in ipairs(entry.drafts) do
		if msg.id == msg_id then
			return msg
		end
	end
	for _, msg in ipairs(entry.trash) do
		if msg.id == msg_id then
			return msg
		end
	end
end

-- get player boxes where a message appears
function mail.get_message_boxes(playername, msg_id)
	local entry = mail.get_storage_entry(playername)
	local boxes = {}
	for _, msg in ipairs(entry.inbox) do
		if msg.id == msg_id then
			table.insert(boxes, "inbox")
		end
	end
	for _, msg in ipairs(entry.outbox) do
		if msg.id == msg_id then
			table.insert(boxes, "outbox")
		end
	end
	for _, msg in ipairs(entry.drafts) do
		if msg.id == msg_id then
			table.insert(boxes, "drafts")
		end
	end
	for _, msg in ipairs(entry.trash) do
		if msg.id == msg_id then
			table.insert(boxes, "trash")
		end
	end
	return boxes
end

local function safe_find(str, sub)
	return str and sub and str:find(sub, 1, true) or nil
end

function mail.sort_messages(messages, sortfield, descending, filter)
	local results = {}
	-- Filtering
	if filter and filter ~= "" then
		for _, msg in ipairs(messages) do
			if safe_find(msg.from, filter) or safe_find(msg.to, filter) or safe_find(msg.subject, filter) then
				table.insert(results, msg)
			end
		end
	else
		for i = 1, #messages do
			results[i] = messages[i]
		end
	end
	-- Sorting
	if sortfield ~= nil then
		if descending then
			table.sort(results, function(a, b) return a[sortfield] > b[sortfield] end)
		else
			table.sort(results, function(a, b) return a[sortfield] < b[sortfield] end)
		end
	end
	return results
end

-- marks a mail read by its id
function mail.mark_read(playername, msg_ids)
	local entry = mail.get_storage_entry(playername)
	if type(msg_ids) ~= "table" then -- if this is not a table
		msg_ids = { msg_ids }
	end
	for _, read_msg_id in ipairs(msg_ids) do
		for _, entry_msg in ipairs(entry.inbox) do
			if entry_msg.id == read_msg_id then
				entry_msg.read = true
			end
		end
	end
	mail.set_storage_entry(playername, entry)
	mail.hud_update(playername, entry.inbox)
	return
end

-- marks a mail unread by its id
function mail.mark_unread(playername, msg_ids)
	local entry = mail.get_storage_entry(playername)
	if type(msg_ids) ~= "table" then -- if this is not a table
		msg_ids = { msg_ids }
	end
	for _, unread_msg_id in ipairs(msg_ids) do
		for _, entry_msg in ipairs(entry.inbox) do
			if entry_msg.id == unread_msg_id then
				entry_msg.read = false
			end
		end
	end
	mail.set_storage_entry(playername, entry)
	return
end

-- deletes a mail by its id
function mail.delete_mail(playername, msg_ids, delete_in_trash)
	local entry = mail.get_storage_entry(playername)
	if type(msg_ids) ~= "table" then -- if this is not a table
		msg_ids = { msg_ids }
	end
	for i = #entry.inbox, 1, -1 do
		for _, deleted_msg in ipairs(msg_ids) do
			if entry.inbox[i].id == deleted_msg then
				table.remove(entry.inbox, i)
				break
			end
		end
	end
	for i = #entry.outbox, 1, -1 do
		for _, deleted_msg in ipairs(msg_ids) do
			if entry.outbox[i].id == deleted_msg then
				table.remove(entry.outbox, i)
				break
			end
		end
	end
	for i = #entry.drafts, 1, -1 do
		for _, deleted_msg in ipairs(msg_ids) do
			if entry.drafts[i].id == deleted_msg then
				table.remove(entry.drafts, i)
				break
			end
		end
	end
	if delete_in_trash then
		for i = #entry.trash, 1, -1 do
			for _, deleted_msg in ipairs(msg_ids) do
				if entry.trash[i].id == deleted_msg then
					table.remove(entry.trash, i)
					break
				end
			end
		end
	end
	mail.set_storage_entry(playername, entry)
	mail.hud_update(playername, entry.inbox)
	return
end

-- move to trash mails by id
function mail.trash_mail(playername, msg_ids)
	local entry = mail.get_storage_entry(playername)
	if type(msg_ids) ~= "table" then -- if this is not a table
		msg_ids = { msg_ids }
	end
	for _, id in ipairs(msg_ids) do
		local msg = mail.get_message(playername, id)
		msg.previous_boxes = mail.get_message_boxes(playername, id)
		table.insert(entry.trash, 1, msg)
	end
	mail.set_storage_entry(playername, entry)
	mail.delete_mail(playername, msg_ids)
	return
end

-- restore a mail from trash
function mail.restore_mail(playername, msg_id)
	local entry = mail.get_storage_entry(playername)
	for i, msg in ipairs(entry.trash) do
		if msg.id == msg_id then
			-- not anymore store previous boxes in json
			local previous_boxes = msg.previous_boxes
			msg.previous_boxes = nil
			-- restore it in all previous boxes
			for _, box in ipairs(previous_boxes) do
				table.insert(entry[box], msg)
			end
			-- then delete it from trash
			table.remove(entry.trash, i)
		end
	end
	mail.set_storage_entry(playername, entry)
	return
end

-- clear the trash
function mail.empty_trash(playername)
	local entry = mail.get_storage_entry(playername)
	entry.trash = {}
	mail.set_storage_entry(playername, entry)
	return
end

-- add or update a contact
function mail.update_contact(playername, contact)
	local entry = mail.get_storage_entry(playername)
	local existing_updated = false
	for i, existing_contact in ipairs(entry.contacts) do
		if existing_contact.name == contact.name then
			-- update
			entry.contacts[i] = contact
			existing_updated = true
			break
		end
	end
	if not existing_updated then
		-- insert
		table.insert(entry.contacts, contact)
	end
	mail.set_storage_entry(playername, entry)
end

-- deletes a contact
function mail.delete_contact(playername, contactname)
	local entry = mail.get_storage_entry(playername)
	for i, existing_contact in ipairs(entry.contacts) do
		if existing_contact.name == contactname then
			-- delete
			table.remove(entry.contacts, i)
			mail.set_storage_entry(playername, entry)
			return
		end
	end
end

-- get all contacts
function mail.get_contacts(playername)
	local entry = mail.get_storage_entry(playername)
	return entry.contacts
end

-- get a contact
function mail.get_contact(playername, contactname)
	local entry = mail.get_storage_entry(playername)
	for _, existing_contact in ipairs(entry.contacts) do
		if existing_contact.name == contactname then
			return existing_contact
		end
	end
	return false
end

-- returns the maillists of a player
function mail.get_maillists(playername)
	local entry = mail.get_storage_entry(playername)
	return entry.lists
end

-- returns the maillists of a player
function mail.get_maillist_by_name(playername, listname)
	local entry = mail.get_storage_entry(playername)
	for _, list in ipairs(entry.lists) do
		if list.name == listname then
			return list
		end
	end
end

-- updates or creates a maillist
function mail.update_maillist(playername, list, old_list_name)
	local entry = mail.get_storage_entry(playername)
	for i, existing_list in ipairs(entry.lists) do
		if existing_list.name == old_list_name then
			-- delete
			table.remove(entry.lists, i)
			break
		end
	end
	-- insert
	table.insert(entry.lists, list)
	mail.set_storage_entry(playername, entry)
end

function mail.delete_maillist(playername, listname)
	local entry = mail.get_storage_entry(playername)
	for i, list in ipairs(entry.lists) do
		if list.name == listname then
			-- delete
			table.remove(entry.lists, i)
			mail.set_storage_entry(playername, entry)
			return
		end
	end
end

function mail.extractMaillists(receivers_string, maillists_owner)
	local receivers = mail.parse_player_list(receivers_string) -- extracted receivers

	-- extract players from mailing lists
	while string.find(receivers_string, "@") do
		local globalReceivers = mail.parse_player_list(receivers_string) -- receivers including maillists
		receivers = {}
		for _, receiver in ipairs(globalReceivers) do
			local receiverInfo = receiver:split("@") -- @maillist
			if receiverInfo[1] and receiver == "@" .. receiverInfo[1] then
				local maillist = mail.get_maillist_by_name(maillists_owner, receiverInfo[1])
				if maillist then
					for _, playername in ipairs(maillist.players) do
						table.insert(receivers, playername)
					end
				end
			else -- in case of player
				table.insert(receivers, receiver)
			end
		end
		receivers_string = mail.concat_player_list(receivers)
	end

	return receivers
end

function mail.get_setting_default_value(setting_name)
	return mail.settings[setting_name].default
end

function mail.get_setting(playername, setting_name)
	local entry = mail.get_storage_entry(playername)
	if entry.settings[setting_name] ~= nil then
		return entry.settings[setting_name]
	else
		return mail.get_setting_default_value(setting_name)
	end
end

-- add or update a setting
function mail.set_setting(playername, key, value)
	local entry = mail.get_storage_entry(playername)
	entry.settings[key] = value
	mail.set_storage_entry(playername, entry)
end

function mail.reset_settings(playername)
	local entry = mail.get_storage_entry(playername)
	entry.settings = {}
	mail.set_storage_entry(playername, entry)
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

