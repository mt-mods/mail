
-- mark mail as unread
function mail.handlers.mark_unread(playername, index)
	local messages = mail.getMessages(playername)
	if messages[index] then
		messages[index].unread = true
	end
	mail.setMessages(playername, messages)
end
