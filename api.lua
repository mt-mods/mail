-- see: mail.md

mail.registered_on_receives = {}
function mail.register_on_receive(func)
	mail.registered_on_receives[#mail.registered_on_receives + 1] = func
end

mail.receive_mail_message = "You have a new message from %s! Subject: %s\nTo view it, type /mail"
mail.read_later_message = "You can read your messages later by using the /mail command"

--[[
mail sending function, can be invoked with one object argument (new api) or
all 4 parameters (old compat version)
see: "Mail format" api.md
--]]
function mail.send(sender, receiver, subject, body)
	local m
	if receiver == nil and subject == nil and body == nil then
		-- new format (one object param)
		m = sender

	else
		-- old format
		-- create mail from params

		m = {}
		m.sender = sender
		m.receiver = receiver
		m.subject = subject
		m.body = body

	end

	m.unread = true

	if not m.time then
		-- add timestamp
		m.time = os.time()
	end


	minetest.log("action", "[mail] '" .. m.sender .. "' sends mail to '" .. m.receiver ..
		"' with subject '" .. m.subject .. "' and body: '" .. m.body .. "'")

	local messages = mail.getMessages(m.receiver)

	table.insert(messages, 1, m)
	mail.setMessages(m.receiver, messages)

	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if name == m.receiver then
			if m.subject == "" then m.subject = "(No subject)" end
			if string.len(m.subject) > 30 then
				m.subject = string.sub(m.subject,1,27) .. "..."
			end
			minetest.chat_send_player(m.receiver,
					string.format(mail.receive_mail_message, m.sender, m.subject))
		end
	end

	for i=1, #mail.registered_on_receives do
		if mail.registered_on_receives[i](m) then
			break
		end
	end
end
