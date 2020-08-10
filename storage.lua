
-- TODO: maybe local cache?

function mail.getMailFile(playername)
	local saneplayername = string.gsub(playername, "[.|/]", "")
	return mail.maildir .. "/" .. saneplayername .. ".json"
end

function mail.getContactsFile(playername)
	local saneplayername = string.gsub(playername, "[.|/]", "")
	return mail.maildir .. "/contacts/" .. saneplayername .. ".json"
end


mail.getMessages = function(playername)
	local messages = mail.read_json_file(mail.getMailFile(playername))
	if messages then
		mail.hud_update(playername, messages)
	end

	return messages
end

mail.setMessages = function(playername, messages)
	if mail.write_json_file(mail.getMailFile(playername), messages) then
		mail.hud_update(playername, messages)
		return true
	else
		minetest.log("error","[mail] Save failed - messages may be lost! ("..playername..")")
		return false
	end
end


mail.getContacts = function(playername)
	return mail.read_json_file(mail.getContactsFile(playername))
end

mail.setContacts = function(playername, contacts)
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
		print(string.format('read from %s:  %s', path, json))
		content = minetest.parse_json(json or "[]") or {}
		file:close()
	end
	return content
end

function mail.write_json_file(path, content)
	local file = io.open(path,"w")
	local json = minetest.write_json(content)
	print(string.format('writing to %s:  %s', path, json))
	if file and file:write(json) and file:close() then
		return true
	else
		return false
	end
end
