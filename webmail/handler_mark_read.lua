
-- mark mail as read
function mail.handlers.mark_read(playername, index)
	local messages = mail.getMessages(playername)
	if messages[index] then
		messages[index].unread = false
	end
	mail.setMessages(playername, messages)
end
