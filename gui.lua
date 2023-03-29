
function mail.compile_contact_list(name, selected, playernames)
	-- TODO: refactor this - not just compiles *a* list, but *the* list for the contacts screen (too inflexible)
	local formspec = {}
	local contacts = mail.get_contacts(name)

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

if minetest.get_modpath("unified_inventory") then
	mail.receive_mail_message = mail.receive_mail_message ..
		" or use the mail button in the inventory"
	mail.read_later_message = mail.read_later_message ..
		" or by using the mail button in the inventory"

	unified_inventory.register_button("mail", {
			type = "image",
			image = "mail_button.png",
			tooltip = "Mail",
			action = function(player)
				mail.show_mail_menu(player:get_player_name())
			end
		})
end
