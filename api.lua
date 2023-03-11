-- see: mail.md

local f = string.format

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
function mail.send(...)
	-- figure out format
	local m
	if #{...} == 1 then
		-- new format (one table param)
		m = ...
		-- populate "to" field
		m.to = m.to or m.dst
		-- populate "from" field
		m.from = m.from or m.src
	else
		-- old format
		m = {}
		m.from, m.to, m.subject, m.body = ...
	end

	-- sane default values
	m.subject = m.subject or ""
	m.body = m.body or ""

	if m.subject == "" then
		m.subject = "(No subject)"
	end
	if string.len(m.subject) > 30 then
		m.subject = string.sub(m.subject,1,27) .. "..."
	end

	-- normalize to, cc and bcc while compiling a list of all recipients
	local recipients = {}
	local undeliverable = {}
	m.to = mail.normalize_players_and_add_recipients(m.to, recipients, undeliverable)
	if m.cc then
		m.cc = mail.normalize_players_and_add_recipients(m.cc, recipients, undeliverable)
	end
	if m.bcc then
		m.bcc = mail.normalize_players_and_add_recipients(m.bcc, recipients, undeliverable)
	end

	if next(undeliverable) then -- table is not empty
		local undeliverable_names = {}
		for name in pairs(undeliverable) do
			undeliverable_names[#undeliverable_names + 1] = '"' .. name .. '"'
		end
		return f("recipients %s don't exist; cannot send mail.",
			table.concat(undeliverable_names, ", ")
		)
	end

	local extra = {}
	local extra_log
	if m.cc then
		table.insert(extra, "CC: " .. m.cc)
	end
	if m.bcc then
		table.insert(extra, "BCC: " .. m.bcc)
	end
	if #extra > 0 then
		extra_log = f(" (%s)", table.concat(extra, " - "))
	else
		extra_log = ""
	end

	minetest.log("action", f("[mail] %q send mail to %q%s with subject %q and body %q",
		m.from, m.to, extra_log, m.subject, m.body
	))

	-- form the actual mail
	local msg = {
		sender  = m.from,
		to      = m.to,
		cc      = m.cc,
		bcc     = m.bcc,
		subject = m.subject,
		body    = m.body,
		time    = os.time(),
	}
	
	-- insert in global storage
	mail.addMessage(msg)

	-- notify recipients that happen to be online
	local mail_alert = f(mail.receive_mail_message, m.from, m.subject)
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if recipients[name] then
			minetest.chat_send_player(name, mail_alert)
		end
	end

	for i=1, #mail.registered_on_receives do
		if mail.registered_on_receives[i](m) then
			break
		end
	end
end
