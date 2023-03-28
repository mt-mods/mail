local FORMNAME = "mail:editcontact"

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
	formspec = formspec .. mail.theme
	formspec = string.format(formspec,
		minetest.formspec_escape(contact_name or ""),
		minetest.formspec_escape(note or ""))
	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()
	local contacts = mail.getPlayerContacts(name)

	if fields.save then
		if mail.selected_idxs.contacts[name] and mail.selected_idxs.contacts[name] ~= "#NEW#" then
			local contact = contacts[mail.selected_idxs.contacts[name]]
			if mail.selected_idxs.contacts[name] ~= string.lower(fields.name) then
				-- name changed!
				if #fields.name == 0 then
					mail.show_edit_contact(name, contact.name, fields.note, "empty")
					return true

				elseif contacts[string.lower(fields.name)] ~= nil then
					mail.show_edit_contact(name, contact.name, fields.note, "collision")
					return true

				else
					mail.setContact(name, contact)
					contacts[mail.selected_idxs.contacts[name]] = nil
				end
			end
			contact.name = fields.name
			contact.note = fields.note
			mail.setContact(name, contact)

		else
			local contact = {
				name = fields.name,
				note = fields.note,
			}
			mail.addContact(name, contact)
		end
		mail.show_contacts(name)

	elseif fields.back then
		mail.show_contacts(name)
	end

	return true
end)