
-- TODO: maybe local cache?

function getMailFile(playername)
	local saneplayername = string.gsub(playername, "[.|/]", "")
	return mail.maildir .. "/" .. saneplayername .. ".json"
end

mail.getMessages = function(playername)
	local file = io.open(getMailFile(playername), "r")
	local messages = {}
	if file then
		local json = file:read("*a")
		messages = minetest.parse_json(json or "[]") or {}
		mail.hud_update(playername, messages)
		file:close()
	end

	return messages
end

mail.setMessages = function(playername, messages)
	local file = io.open(getMailFile(playername),"w")
	local json = minetest.write_json(messages)
	if file and file:write(json) and file:close() then
		mail.hud_update(playername, messages)
		return true
	else
		minetest.log("error","[mail] Save failed - messages may be lost!")
		return false
	end
end
