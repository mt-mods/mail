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

TODO: refactor this garbage code!
--]]
function mail.send(src, dst, subject, body)
	-- figure out format
	local m
	if dst == nil and subject == nil and body == nil then
		-- new format (one object param)
		m = src
	else
		-- old format
		m = {}
		m.from = src
		m.to = dst
		m.subject = subject
		m.body = body
	end

	if m.dst and not m.to then
		-- populate "to" field
		m.to = m.dst
	end

	if m.src and not m.from then
		-- populate "from" field
		m.from = m.src
	end

	-- sane default values
	m.subject = m.subject or ""
	m.body = m.body or ""

	local cc
	local bcc
	local extra
	-- log mail send action
	if m.cc or m.bcc then
		if m.cc then
			cc = "CC: " .. m.cc
			if m.bcc then
				cc = cc .. " - "
			end
		else
			cc = ""
		end
		if m.bcc then
			bcc = "BCC: " .. m.bcc
		else
			bcc = ""
		end
		extra = " (" .. cc .. bcc .. ")"
	else
		extra = ""
	end
	minetest.log("action", "[mail] '" .. m.from .. "' sends mail to '" .. m.to .. "'" ..
		extra .. "' with subject '" .. m.subject .. "' and body: '" .. m.body .. "'")


	-- normalize to, cc and bcc while compiling a list of all recipients
	local recipients = {}
	m.to = mail.normalize_players_and_add_recipients(m.to, recipients)
	if m.cc then
		m.cc = mail.normalize_players_and_add_recipients(m.cc, recipients)
	end
	if m.bcc then
		m.bcc = mail.normalize_players_and_add_recipients(m.bcc, recipients)
	end

	-- form the actual mail
	local msg = {
		unread  = true,
		sender  = m.from,
		to      = m.to,
		subject = m.subject,
		body    = m.body,
		time    = os.time(),
	}
	if m.cc then
		msg.cc  = m.cc
	end

	-- send the mail to all recipients
	for _, recipient in pairs(recipients) do
		local messages = mail.getMessages(recipient)
		table.insert(messages, 1, msg)
		mail.setMessages(recipient, messages)
	end

	-- notify recipients that happen to be online
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if recipients[string.lower(name)] ~= nil then
			if m.subject == "" then m.subject = "(No subject)" end
			if string.len(m.subject) > 30 then
				m.subject = string.sub(m.subject,1,27) .. "..."
			end
			minetest.chat_send_player(name,
					string.format(mail.receive_mail_message, m.from, m.subject))
		end
	end

	for i=1, #mail.registered_on_receives do
		if mail.registered_on_receives[i](m) then
			break
		end
	end
end
