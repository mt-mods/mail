-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:editcontact"

function mail.show_edit_contact(name, contact_name, note, illegal_name_hint)
	local formspec = [[
			size[6,7]
			button[4,6.25;2,0.5;back;]] .. S("Back") .. [[]
			field[0.25,0.5;4,1;name;]] .. S("Player name") .. [[:;%s]
			textarea[0.25,1.6;4,6.25;note;]] .. S("Note") .. [[:;%s]
			button[4,0.10;2,1;save;]] .. S("Save") .. [[]
		]]
	if illegal_name_hint == "collision" then
		formspec = formspec .. [[
			textarea[4.25,1;2.5,6;;;]] ..
			S("That name is already in your contacts") .. [[]
			]]
	elseif illegal_name_hint == "empty" then
		formspec = formspec .. [[
			textarea[4.25,1;2.5,6;;;]] ..
			S("The contact name cannot be empty.") .. [[]
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
	local contacts = mail.get_contacts(name)

	if fields.save then
		if mail.selected_idxs.contacts[name] then
			local contact = contacts[mail.selected_idxs.contacts[name]] or {name = ""}
			if contact.name ~= fields.name or fields.name == "" then
				-- name changed!
				if #fields.name == 0 then
					mail.show_edit_contact(name, contact.name, fields.note, "empty")
					return true

				elseif mail.get_contact(name, fields.name) then
					mail.show_edit_contact(name, contact.name, fields.note, "collision")
					return true

				else
					contact.name = fields.name
					contact.note = fields.note
					mail.update_contact(name, contact)
					contacts[mail.selected_idxs.contacts[name]] = nil
				end
			end
			contact.name = fields.name
			contact.note = fields.note
			mail.update_contact(name, contact)

		else
			mail.update_contact(name, {
				name = fields.name,
				note = fields.note,
			})
		end
		mail.show_contacts(name)

	elseif fields.back then
		mail.show_contacts(name)
	end

	return true
end)
