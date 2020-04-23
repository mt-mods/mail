-- remove mail
function mail.handlers.delete(playername, index)
	local messages = mail.getMessages(playername)
	if messages[index] then
		table.remove(messages, index)
	end
	mail.setMessages(playername, messages)
end
