-- get player messages request from webmail
function mail.handlers.messages(playername)
	local messages = mail.getMessages(playername)
	mail.channel.send({
		type = "player-messages",
		playername = playername,
		data = messages
	})
end
