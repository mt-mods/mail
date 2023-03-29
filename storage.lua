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
	local messages = mail.read_json_file(mail.getMailFile(playername))
	if messages then
		for _, msg in ipairs(messages) do
			if not msg.time then
				-- add missing time field if not available (happens with old data)
				msg.time = 0
			end
		end

		-- sort by received date descending
		table.sort(messages, function(a,b) return a.time > b.time end)
		-- show hud notification
		mail.hud_update(playername, messages)
	end

	return messages
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
	table.insert(messages, 1, message)
	if mail.write_json_file(mail.maildir .. "/mail.messages.json", messages) then
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
