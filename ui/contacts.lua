-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:contacts"

local contacts_formspec = "size[8,9;]" .. mail.theme .. [[
		button[6,0.10;2,0.5;new;]] .. S("New") .. [[]
		button[6,0.85;2,0.5;edit;]] .. S("Edit") .. [[]
		button[6,1.60;2,0.5;delete;]] .. S("Delete") .. [[]
		button[6,8.25;2,0.5;back;]] .. S("Back") .. [[]
		tablecolumns[color;text;text]
		table[0,0;5.75,9;contacts;]] .. mail.get_color("header") .. "," .. S("Name") .. "," .. S("Note")


function mail.show_contacts(name)
    local formspec = contacts_formspec .. mail.compile_contact_list(name, mail.selected_idxs.contacts[name])
    minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()
	local contacts = mail.get_contacts(name)

	if fields.contacts then
		local evt = minetest.explode_table_event(fields.contacts)
		for k, _, i in mail.pairsByKeys(contacts) do
			if i == evt.row - 1 then
				mail.selected_idxs.contacts[name] = tonumber(k)
				break
			end
		end
		if evt.type == "DCL" and contacts[mail.selected_idxs.contacts[name]] then
			mail.show_edit_contact(
				name,
				contacts[mail.selected_idxs.contacts[name]].name,
				contacts[mail.selected_idxs.contacts[name]].note
			)
		end

	elseif fields.new then
		mail.selected_idxs.contacts[name] = "#NEW#"
		mail.show_edit_contact(name, "", "")

	elseif fields.edit and mail.selected_idxs.contacts[name] and contacts[mail.selected_idxs.contacts[name]] then
		mail.show_edit_contact(
			name,
			contacts[mail.selected_idxs.contacts[name]].name,
			contacts[mail.selected_idxs.contacts[name]].note
		)

	elseif fields.delete then
		if contacts[mail.selected_idxs.contacts[name]] then
			-- delete the contact and set the selected to the next in the list,
			-- except if it was the last. Then determine the new last
			local found = false
			local last = nil
			for k in mail.pairsByKeys(contacts) do
				if found then
					mail.selected_idxs.contacts[name] = tonumber(k)
					break
				elseif k == mail.selected_idxs.contacts[name] then
					mail.delete_contact(name, contacts[mail.selected_idxs.contacts[name]].name)
					mail.selected_idxs.contacts[name] = nil
					found = true
				else
					last = tonumber(k)
				end
			end
			if found and not mail.selected_idxs.contacts[name] then
				-- was the last in the list, so take the previous (new last)
				mail.selected_idxs.contacts[name] = last
			end
		end

		mail.show_contacts(name)

	elseif fields.back then
		mail.show_mail_menu(name)
	end

	return true
end)
