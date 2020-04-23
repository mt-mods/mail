function mail.webmail_send_hook(m)
	mail.channel.send({
		type = "new-message",
		data = m
	})
end

mail.register_on_receive(mail.webmail_send_hook)
