-- refactor these to some proper management thing
selected_idxs = {
	messages = {},
	contacts = {},
	to = {},
	cc = {},
	bcc = {},
}
message_drafts = {}

local theme
if minetest.get_modpath("default") then
	theme = default.gui_bg .. default.gui_bg_img
else
	theme = ""
end

mail.inbox_formspec = "size[8,9;]" .. theme .. [[
		button[6,0.10;2,0.5;new;New]
		button[6,0.95;2,0.5;read;Read]
		button[6,1.70;2,0.5;reply;Reply]
		button[6,2.45;2,0.5;replyall;Reply All]
		button[6,3.20;2,0.5;forward;Forward]
		button[6,3.95;2,0.5;delete;Delete]
		button[6,4.82;2,0.5;markread;Mark Read]
		button[6,5.55;2,0.5;markunread;Mark Unread]
		button[6,6.55;2,0.5;contacts;Contacts]
		button[6,7.40;2,0.5;about;About]
		button_exit[6,8.45;2,0.5;quit;Close]

		tablecolumns[color;text;text]
		table[0,0;5.75,9;messages;#999,From,Subject]]

mail.contacts_formspec = "size[8,9;]" .. theme .. [[
		button[6,0.10;2,0.5;new;New]
		button[6,0.85;2,0.5;edit;Edit]
		button[6,1.60;2,0.5;delete;Delete]
		button[6,8.25;2,0.5;back;Back]
		tablecolumns[color;text;text]
		table[0,0;5.75,9;contacts;#999,Name,Note]]

mail.select_contact_formspec = "size[8,9;]" .. theme .. [[
		tablecolumns[color;text;text]
		table[0,0;3.5,9;contacts;#999,Name,Note%s]
		button[3.55,2.00;1.75,0.5;toadd;→ Add]
		button[3.55,2.75;1.75,0.5;toremove;← Remove]
		button[3.55,6.00;1.75,0.5;ccadd;→ Add]
		button[3.55,6.75;1.75,0.5;ccremove;← Remove]
		tablecolumns[color;text;text]
		table[5.15,0.0;2.75,4.5;to;#999,TO:,Note%s]
		tablecolumns[color;text;text]
		table[5.15,4.6;2.75,4.5;cc;#999,CC:,Note%s]
		button[3.55,8.25;1.75,0.5;back;Back]
	]]


function mail.show_about(name)
	local formspec = [[
			size[8,5;]
			button[7.25,0;0.75,0.5;back;X]
			label[0,0;Mail]
			label[0,0.5;By cheapie]
			label[0,1;http://github.com/cheapie/mail]
			label[0,1.5;See LICENSE file for license information]
			label[0,2.5;NOTE: Communication using this system]
			label[0,3;is NOT guaranteed to be private!]
			label[0,3.5;Admins are able to view the messages]
			label[0,4;of any player.]
		]] .. theme

	minetest.show_formspec(name, "mail:about", formspec)
end

function mail.show_inbox(name)
	local formspec = { mail.inbox_formspec }
	local messages = mail.getMessages(name)

	message_drafts[name] = nil

	if messages[1] then
		for _, message in ipairs(messages) do
			mail.ensure_new_format(message, name)
			if message.unread then
				if not mail.player_in_list(name, message.to) then
					formspec[#formspec + 1] = ",#FFD788"
				else
					formspec[#formspec + 1] = ",#FFD700"
				end
			else
				if not mail.player_in_list(name, message.to) then
					formspec[#formspec + 1] = ",#CCCCDD"
				else
					formspec[#formspec + 1] = ","
				end
			end
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = minetest.formspec_escape(message.sender)
			formspec[#formspec + 1] = ","
			if message.subject ~= "" then
				if string.len(message.subject) > 30 then
					formspec[#formspec + 1] =
							minetest.formspec_escape(string.sub(message.subject, 1, 27))
					formspec[#formspec + 1] = "..."
				else
					formspec[#formspec + 1] = minetest.formspec_escape(message.subject)
				end
			else
				formspec[#formspec + 1] = "(No subject)"
			end
		end
		if selected_idxs.messages[name] then
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = tostring(selected_idxs.messages[name] + 1)
		end
		formspec[#formspec + 1] = "]"
	else
		formspec[#formspec + 1] = "]label[2.25,4.5;No mail]"
	end
	minetest.show_formspec(name, "mail:inbox", table.concat(formspec, ""))
end

function mail.show_contacts(name)
	local formspec = mail.contacts_formspec .. mail.compile_contact_list(name, selected_idxs.contacts[name])
	minetest.show_formspec(name, "mail:contacts", formspec)
end

function mail.show_edit_contact(name, contact_name, note, illegal_name_hint)
	local formspec = [[
			size[6,7]
			button[4,6.25;2,0.5;back;Back]
			field[0.25,0.5;4,1;name;Player name:;%s]
			textarea[0.25,1.6;4,6.25;note;Note:;%s]
			button[4,0.10;2,1;save;Save]
		]]
	if illegal_name_hint == "collision" then
		formspec = formspec .. [[
				label[4,1;That name]
				label[4,1.5;is already in]
				label[4,2;your contacts.]
			]]
	elseif illegal_name_hint == "empty" then
		formspec = formspec .. [[
				label[4,1;The contact]
				label[4,1.5;name cannot]
				label[4,2;be empty.]
			]]
	end
	formspec = formspec .. theme
	formspec = string.format(formspec,
		minetest.formspec_escape(contact_name or ""),
		minetest.formspec_escape(note or ""))
	minetest.show_formspec(name, "mail:editcontact", formspec)
end

function mail.show_select_contact(name, to, cc)
	local formspec = mail.select_contact_formspec
	local contacts = mail.compile_contact_list(name, selected_idxs.contacts[name])

	-- compile lists
	if to then
		to = mail.compile_contact_list(name, selected_idxs.to[name], to)
	else
		to = ""
	end
	if cc then
		cc = mail.compile_contact_list(name, selected_idxs.cc[name], cc)
	else
		cc = ""
	end
	--[[if bcc then
		bcc = table.concat(mail.compile_contact_list(name, selected_idxs.bcc[name], bcc)
	else
		bcc = ""
	end]]--
	formspec = string.format(formspec, contacts, to, cc)--, bcc()
	minetest.show_formspec(name, "mail:selectcontact", formspec)
end

function mail.compile_contact_list(name, selected, playernames)
	-- TODO: refactor this - not just compiles *a* list, but *the* list for the contacts screen (too inflexible)
	local formspec = {}
	local contacts = mail.getContacts(name)

	if playernames == nil then
		local length = 0
		for k, contact, i, l in mail.pairsByKeys(contacts) do
			if i == 1 then length = l end
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = minetest.formspec_escape(contact.name)
			formspec[#formspec + 1] = ","
			local note = contact.note
			-- display an ellipsis if the note spans multiple lines
			local idx = string.find(note, '\n')
			if idx ~= nil then
				note = string.sub(note, 1, idx-1) .. ' ...'
			end
			formspec[#formspec + 1] = minetest.formspec_escape(note)
			if type(selected) == "string" then
				if string.lower(selected) == k then
					selected = i
				end
			end
		end
		if length > 0 then
			if selected and type(selected) == "number" then
				formspec[#formspec + 1] = ";"
				formspec[#formspec + 1] = tostring(selected + 1)
			end
			formspec[#formspec + 1] = "]"
		else
			formspec[#formspec + 1] = "]label[2,4.5;No contacts]"
		end
	else
		if type(playernames) == "string" then
			playernames = mail.parse_player_list(playernames)
		end
		for i,c in ipairs(playernames) do
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = minetest.formspec_escape(c)
			formspec[#formspec + 1] = ","
			if contacts[string.lower(c)] == nil then
				formspec[#formspec + 1] = ""
			else
				local note = contacts[string.lower(c)].note
				-- display an ellipsis if the note spans multiple lines
				local idx = string.find(note, '\n')
				if idx ~= nil then
					note = string.sub(note, 1, idx-1) .. ' ...'
				end
				formspec[#formspec + 1] = minetest.formspec_escape(note)
			end
			if not selected then
				if type(selected) == "string" then
					if string.lower(selected) == string.lower(c) then
						selected = i
					end
				end
			end
		end
		if #playernames > 0 and selected and type(selected) == "number" then
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = tostring(selected + 1)
		end
		formspec[#formspec + 1] = "]"
	end
	return table.concat(formspec, "")
end

function mail.show_message(name, msgnumber)
	local messages = mail.getMessages(name)
	local message = messages[msgnumber]
	local formspec = [[
			size[8,9]
			button[7.25,0;0.75,0.5;back;X]
			label[0,0;From: %s]
			label[0,0.4;To: %s]
			label[0,0.8;CC: %s]
			label[0,1.3;Subject: %s]
			textarea[0.25,1.8;8,7.8;;;%s]
			button[0,8.5;2,1;reply;Reply]
			button[2,8.5;2,1;replyall;Reply All]
			button[4,8.5;2,1;forward;Forward]
			button[6,8.5;2,1;delete;Delete]
		]] .. theme

	local from = minetest.formspec_escape(message.sender) or ""
	local to = minetest.formspec_escape(message.to) or ""
	local cc = minetest.formspec_escape(message.cc) or ""
	local subject = minetest.formspec_escape(message.subject) or ""
	local body = minetest.formspec_escape(message.body) or ""
	formspec = string.format(formspec, from, to, cc, subject, body)

	if message.unread then
		message.unread = false
		mail.setMessages(name, messages)
	end

	minetest.show_formspec(name,"mail:message",formspec)
end

function mail.show_compose(name, defaultto, defaultsubj, defaultbody, defaultcc, defaultbcc)
	local formspec = [[
			size[8,9]
			button[0,0;1,1;tocontacts;To:]
			field[1.1,0.3;3.2,1;to;;%s]
			button[4,0;1,1;cccontacts;CC:]
			field[5.1,0.3;3.1,1;cc;;%s]
			button[4,0.75;1,1;bcccontacts;BCC:]
			field[5.1,1.05;3.1,1;bcc;;%s]
			field[0.25,2;8,1;subject;Subject:;%s]
			textarea[0.25,2.5;8,6;body;;%s]
			button[0.5,8.5;3,1;cancel;Cancel]
			button[4.5,8.5;3,1;send;Send]
		]] .. theme

	defaultto = defaultto or ""
	defaultsubj = defaultsubj or ""
	defaultbody = defaultbody or ""
	defaultcc = defaultcc or ""
	defaultbcc = defaultbcc or ""

	formspec = string.format(formspec,
		minetest.formspec_escape(defaultto),
		minetest.formspec_escape(defaultcc),
		minetest.formspec_escape(defaultbcc),
		minetest.formspec_escape(defaultsubj),
		minetest.formspec_escape(defaultbody))

	minetest.show_formspec(name, "mail:compose", formspec)
end

function mail.reply(name, message)
	mail.ensure_new_format(message)
	local replyfooter = "Type your reply here.\n\n--Original message follows--\n" ..message.body
	mail.show_compose(name, message.sender, "Re: "..message.subject, replyfooter)
end

function mail.replyall(name, message)
	mail.ensure_new_format(message)
	local replyfooter = "Type your reply here.\n\n--Original message follows--\n" ..message.body

	-- new recipients are the sender plus the original recipients, minus ourselves
	local recipients = message.to or ""
	if message.sender ~= nil then
		recipients = message.sender .. ", " .. recipients
	end
	recipients = mail.parse_player_list(recipients)
	for k,v in pairs(recipients) do
		if v == name then
			table.remove(recipients, k)
			break
		end
	end
	recipients = mail.concat_player_list(recipients)

	-- new CC is old CC minus ourselves
	local cc = mail.parse_player_list(message.cc)
	for k,v in pairs(cc) do
		if v == name then
			table.remove(cc, k)
			break
		end
	end
	cc = mail.concat_player_list(cc)

	mail.show_compose(name, recipients, "Re: "..message.subject, replyfooter, cc)
end

function mail.forward(name, message)
	local fwfooter = "Type your message here.\n\n--Original message follows--\n" .. (message.body or "")
	mail.show_compose(name, "", "Fw: " .. (message.subject or ""), fwfooter)
end

function mail.handle_receivefields(player, formname, fields)
	if formname == "" and fields and fields.quit and minetest.get_modpath("unified_inventory") then
		unified_inventory.set_inventory_formspec(player, "craft")
	end

	if formname == "mail:about" then
		minetest.after(0.5, function()
			mail.show_inbox(player:get_player_name())
		end)

	elseif formname == "mail:inbox" then
		local name = player:get_player_name()
		local messages = mail.getMessages(name)

		if fields.messages then
			local evt = minetest.explode_table_event(fields.messages)
			selected_idxs.messages[name] = evt.row - 1
			if evt.type == "DCL" and messages[selected_idxs.messages[name]] then
				mail.show_message(name, selected_idxs.messages[name])
			end
			return true
		end
		if fields.read then
			if messages[selected_idxs.messages[name]] then
				mail.show_message(name, selected_idxs.messages[name])
			end

		elseif fields.delete then
			if messages[selected_idxs.messages[name]] then
				table.remove(messages, selected_idxs.messages[name])
				mail.setMessages(name, messages)
			end

			mail.show_inbox(name)
		elseif fields.reply and messages[selected_idxs.messages[name]] then
			local message = messages[selected_idxs.messages[name]]
			mail.reply(name, message)

		elseif fields.replyall and messages[selected_idxs.messages[name]] then
			local message = messages[selected_idxs.messages[name]]
			mail.replyall(name, message)

		elseif fields.forward and messages[selected_idxs.messages[name]] then
			local message = messages[selected_idxs.messages[name]]
			mail.forward(name, message)

		elseif fields.markread then
			if messages[selected_idxs.messages[name]] then
				messages[selected_idxs.messages[name]].unread = false
				-- set messages immediately, so it shows up already when updating the inbox
				mail.setMessages(name, messages)
			end
			mail.show_inbox(name)
			return true

		elseif fields.markunread then
			if messages[selected_idxs.messages[name]] then
				messages[selected_idxs.messages[name]].unread = true
				-- set messages immediately, so it shows up already when updating the inbox
				mail.setMessages(name, messages)
			end
			mail.show_inbox(name)
			return true

		elseif fields.new then
			mail.show_compose(name)

		elseif fields.contacts then
			mail.show_contacts(name)

		elseif fields.quit then
			if minetest.get_modpath("unified_inventory") then
				unified_inventory.set_inventory_formspec(player, "craft")
			end

		elseif fields.about then
			mail.show_about(name)

		end

		return true
	elseif formname == "mail:message" then
		local name = player:get_player_name()
		local messages = mail.getMessages(name)

		if fields.back then
			mail.show_inbox(name)
			return true	-- don't uselessly set messages
		elseif fields.reply then
			local message = messages[selected_idxs.messages[name]]
			mail.reply(name, message)
		elseif fields.replyall then
			local message = messages[selected_idxs.messages[name]]
			mail.replyall(name, message)
		elseif fields.forward then
			local message = messages[selected_idxs.messages[name]]
			mail.forward(name, message.subject)
		elseif fields.delete then
			if messages[selected_idxs.messages[name]] then
				table.remove(messages,selected_idxs.messages[name])
				mail.setMessages(name, messages)
			end
			mail.show_inbox(name)
		end
		return true

	elseif formname == "mail:compose" then
		local name = player:get_player_name()
		if fields.send then
			mail.send({
				from = name,
				to = fields.to,
				cc = fields.cc,
				bcc = fields.bcc,
				subject = fields.subject,
				body = fields.body,
			})
			local contacts = mail.getContacts(name)
			local recipients = mail.parse_player_list(fields.to)
			local changed = false
			for _,v in pairs(recipients) do
				if contacts[string.lower(v)] == nil then
					contacts[string.lower(v)] = {
						name = v,
						note = "",
					}
					changed = true
				end
			end
			if changed then
				mail.setContacts(name, contacts)
			end

			minetest.after(0.5, function()
				mail.show_inbox(name)
			end)

		elseif fields.tocontacts or fields.cccontacts or fields.bcccontacts then
			message_drafts[name] = {
				to = fields.to,
				cc = fields.cc,
				bcc = fields.bcc,
				subject = fields.subject,
				body = fields.body,
			}
			mail.show_select_contact(name, fields.to, fields.cc, fields.bcc)
		elseif fields.cancel then
			message_drafts[name] = nil
			mail.show_inbox(name)
		end
		return true

	elseif formname == "mail:selectcontact" then
		local name = player:get_player_name()
		local contacts = mail.getContacts(name)
		local draft = message_drafts[name]

		-- get indexes for fields with selected rows
		-- execute their default button's actions if double clicked
		for k,action in pairs({
			contacts = "toadd",
			to = "toremove",
			cc = "ccremove",
			bcc = "bccremove"
		}) do
			if fields[k] then
				local evt = minetest.explode_table_event(fields[k])
				selected_idxs[k][name] = evt.row - 1
				if evt.type == "DCL" and selected_idxs[k][name] then
					fields[action] = true
				end
				return true
			end
		end

		local update = false
		-- add
		for _,v in pairs({"to","cc","bcc"}) do
			if fields[v.."add"] then
				update = true
				if selected_idxs.contacts[name] then
					for k, contact, i in mail.pairsByKeys(contacts) do
						if k == selected_idxs.contacts[name] or i == selected_idxs.contacts[name] then
							local list = mail.parse_player_list(draft[v])
							list[#list+1] = contact.name
							selected_idxs[v][name] = #list
							draft[v] = mail.concat_player_list(list)
							break
						end
					end
				end
			end
		end
		-- remove
		for _,v in pairs({"to","cc","bcc"}) do
			if fields[v.."remove"] then
				update = true
				if selected_idxs[v][name] then
					local list = mail.parse_player_list(draft[v])
					table.remove(list, selected_idxs[v][name])
					if #list < selected_idxs[v][name] then
						selected_idxs[v][name] = #list
					end
					draft[v] = mail.concat_player_list(list)
				end
			end
		end
		if update then
			mail.show_select_contact(name, draft.to, draft.cc, draft.bcc)
			return true
		end

		-- delete old idxs
		for _,v in ipairs({"contacts","to","cc","bcc"}) do
			selected_idxs[v][name] = nil
		end
		mail.show_compose(name, draft.to, draft.subject, draft.body, draft.cc, draft.bcc)
		return true

	elseif formname == "mail:contacts" then
		local name = player:get_player_name()
		local contacts = mail.getContacts(name)

		if fields.contacts then
			local evt = minetest.explode_table_event(fields.contacts)
			for k, _, i in mail.pairsByKeys(contacts) do
				if i == evt.row - 1 then
					selected_idxs.contacts[name] = k
					break
				end
			end
			if evt.type == "DCL" and contacts[selected_idxs.contacts[name]] then
				mail.show_edit_contact(
					name,
					contacts[selected_idxs.contacts[name]].name,
					contacts[selected_idxs.contacts[name]].note
				)
			end
			return true
		elseif fields.new then
			selected_idxs.contacts[name] = "#NEW#"
			mail.show_edit_contact(name, "", "")
		elseif fields.edit and selected_idxs.contacts[name] and contacts[selected_idxs.contacts[name]] then
			mail.show_edit_contact(
				name,
				contacts[selected_idxs.contacts[name]].name,
				contacts[selected_idxs.contacts[name]].note
			)
		elseif fields.delete then
			if contacts[selected_idxs.contacts[name]] then
				-- delete the contact and set the selected to the next in the list,
				-- except if it was the last. Then determine the new last
				local found = false
				local last = nil
				for k in mail.pairsByKeys(contacts) do
					if found then
						selected_idxs.contacts[name] = k
						break
					elseif k == selected_idxs.contacts[name] then
						contacts[selected_idxs.contacts[name]] = nil
						selected_idxs.contacts[name] = nil
						found = true
					else
						last = k
					end
				end
				if found and not selected_idxs.contacts[name] then
					-- was the last in the list, so take the previous (new last)
					selected_idxs.contacts[name] = last
				end

				mail.setContacts(name, contacts)
			end

			mail.show_contacts(name)

		elseif fields.back then
			mail.show_inbox(name)

		end
	elseif formname == "mail:editcontact" then
		local name = player:get_player_name()
		local contacts = mail.getContacts(name)

		if fields.save then
			if selected_idxs.contacts[name] and selected_idxs.contacts[name] ~= "#NEW#" then
				local contact = contacts[selected_idxs.contacts[name]]
				if selected_idxs.contacts[name] ~= string.lower(fields.name) then
					-- name changed!
					if #fields.name == 0 then
						mail.show_edit_contact(name, contact.name, fields.note, "empty")
						return true
					elseif contacts[string.lower(fields.name)] ~= nil then
						mail.show_edit_contact(name, contact.name, fields.note, "collision")
						return true
					else
						contacts[string.lower(fields.name)] = contact
						contacts[selected_idxs.contacts[name]] = nil
					end
				end
				contact.name = fields.name
				contact.note = fields.note
			else
				local contact = {
					name = fields.name,
					note = fields.note,
				}
				contacts[string.lower(contact.name)] = contact
			end
			mail.setContacts(name, contacts)
			mail.show_contacts(name)

		elseif fields.back then
			mail.show_contacts(name)

		end

	elseif fields.mail then
		mail.show_inbox(player:get_player_name())
	else
		return false
	end
end

minetest.register_on_player_receive_fields(mail.handle_receivefields)


if minetest.get_modpath("unified_inventory") then
	mail.receive_mail_message = mail.receive_mail_message ..
		" or use the mail button in the inventory"
	mail.read_later_message = mail.read_later_message ..
		" or by using the mail button in the inventory"

	unified_inventory.register_button("mail", {
			type = "image",
			image = "mail_button.png",
			tooltip = "Mail"
		})
end
