-- storage getter/setter
local STORAGE_PREFIX = "mail/"

-- create or populate empty fields on an entry
local function populate_entry(e)
	e = e or {}
	e.contacts = e.contacts or {}
	e.inbox = e.inbox or {}
	e.outbox = e.outbox or {}
	e.drafts = e.drafts or {}
	e.lists = e.lists or {}
	return e
end

function mail.get_storage_entry(playername)
	local str = mail.storage:get_string(STORAGE_PREFIX .. playername)
	if str == "" then
		-- new entry
		return populate_entry()
	else
		-- deserialize existing entry
		local e = minetest.parse_json(str)
		return populate_entry(e)
	end
end

function mail.set_storage_entry(playername, entry)
	mail.storage:set_string(STORAGE_PREFIX .. playername, minetest.write_json(entry))
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

function mail.sort_messages(unsorted_messages, sortfield, sortdirection)
    local messages = {}
    if not sortfield or sortfield == "" then
        sortfield = "3"
    end
    if not sortdirection or sortdirection == "" then
		sortdirection = "1"
	end

	if unsorted_messages[1] then
		-- add first message
		table.insert(messages, unsorted_messages[1])
		table.remove(unsorted_messages, 1)
		-- sort messages
		for _, unsorted_msg in ipairs(unsorted_messages) do
			local is_message_sorted = false
			for j, sorted_msg in ipairs(messages) do
				if sortfield == "1" and unsorted_msg.from >= sorted_msg.from then -- for inbox
					table.insert(messages, j, unsorted_msg)
					is_message_sorted = true
					break
				elseif sortfield == "1" and unsorted_msg.to >= sorted_msg.to then -- for outbox
					table.insert(messages, j, unsorted_msg)
					is_message_sorted = true
					break
				elseif sortfield == "2" and unsorted_msg.subject >= sorted_msg.subject then
					table.insert(messages, j, unsorted_msg)
					is_message_sorted = true
					break
				elseif sortfield == "3" and unsorted_msg.time >= sorted_msg.time then
					table.insert(messages, j, unsorted_msg)
					is_message_sorted = true
					break
				end
			end
			if not is_message_sorted then
				table.insert(messages, 1, unsorted_msg)
			end
		end
	end

	-- reverse for descending

	local sorted_messages = messages

	if sortdirection == "2" then
		sorted_messages = {}
		for i=#messages, 1, -1 do
			sorted_messages[#sorted_messages+1] = messages[i]
		end
	end

	return sorted_messages
end

function mail.filter_messages(unfiltered_messages, filter)
	if not filter or filter == "" then
		return unfiltered_messages
	end

	local filtered_messages = {}

	for _, msg in ipairs(unfiltered_messages) do
		if string.find(msg.from, filter) or string.find(msg.to, filter) or string.find(msg.subject, filter) then
			table.insert(filtered_messages, msg)
		end
	end

	return filtered_messages
end

-- marks a mail read by its id
function mail.mark_read(playername, msg_id)
	local entry = mail.get_storage_entry(playername)
	for _, msg in ipairs(entry.inbox) do
		if msg.id == msg_id then
			msg.read = true
			mail.set_storage_entry(playername, entry)
			mail.hud_update(playername, entry.inbox)
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
			table.remove(entry.inbox, i)
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
	for i, msg in ipairs(entry.drafts) do
		if msg.id == msg_id then
			table.remove(entry.drafts, i)
			mail.set_storage_entry(playername, entry)
			return
		end
	end
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

