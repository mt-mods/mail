-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:maillists"

local owned_maillists_formspec = "size[8,9;]" .. mail.theme .. [[
		tabheader[0.3,1;mailliststab;]] .. S("Owned lists") .. "," .. S("Public lists") .. [[;1;false;false]

		button[6,0.80;2,0.5;new;]] .. S("New") .. [[]
		button[6,1.55;2,0.5;edit;]] .. S("Edit") .. [[]
		button[6,2.30;2,0.5;delete;]] .. S("Delete") .. [[]
		button[6,8.4;2,0.5;back;]] .. S("Back") .. [[]
		tablecolumns[color;text;text]
		table[0,0.7;5.75,8.3;maillists;#999,]] .. S("Name") .. "," .. S("Desc")

function mail.show_owned_maillists(name)
	local formspec = { owned_maillists_formspec }
	local maillists = mail.get_maillists(name)

	if maillists[1] then
		for _, maillist in ipairs(maillists) do
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = "@" .. minetest.formspec_escape(maillist.name)
			formspec[#formspec + 1] = ","
			if maillist.desc ~= "" then
				if string.len(maillist.desc) > 30 then
					formspec[#formspec + 1] = minetest.formspec_escape(string.sub(maillist.desc, 1, 27))
					formspec[#formspec + 1] = "..."
				else
					formspec[#formspec + 1] = minetest.formspec_escape(maillist.desc)
				end
			else
				formspec[#formspec + 1] = S("(No description)")
			end
		end
		if mail.selected_idxs.owned_maillists[name] then
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = mail.selected_idxs.owned_maillists[name]
		end
		formspec[#formspec + 1] = "]"
	else
		formspec[#formspec + 1] = "]label[2.25,4.5;" .. S("No maillist") .. "]"
	end
	minetest.show_formspec(name, FORMNAME, table.concat(formspec, ""))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()
	local maillists = mail.get_maillists(name)

	if fields.maillists then
		local evt = minetest.explode_table_event(fields.maillists)
		mail.selected_idxs.owned_maillists[name] = evt.row - 1
		if evt.type == "DCL" and maillists[mail.selected_idxs.owned_maillists[name]] then
			local maillist = mail.get_maillist_by_name(name, maillists[mail.selected_idxs.owned_maillists[name]].name)
			local players_string = mail.concat_player_list(maillist.players)
			mail.show_edit_maillist(
				name,
				maillists[mail.selected_idxs.owned_maillists[name]].name,
				maillists[mail.selected_idxs.owned_maillists[name]].desc,
				players_string
			)
		end

	elseif fields.new then
		mail.selected_idxs.owned_maillists[name] = "#NEW#"
		mail.show_edit_maillist(name, "", "", "Player1, Player2, Player3")

	elseif fields.edit and maillists[mail.selected_idxs.owned_maillists[name]] then
		local maillist = mail.get_maillist_by_name(name, maillists[mail.selected_idxs.owned_maillists[name]].name)
		local players_string = mail.concat_player_list(maillist.players)
		mail.show_edit_maillist(
			name,
			maillists[mail.selected_idxs.owned_maillists[name]].name,
			maillists[mail.selected_idxs.owned_maillists[name]].desc,
			players_string
		)

	elseif fields.delete then
		if maillists[mail.selected_idxs.owned_maillists[name]] then
			-- delete the maillist and set the selected to the next in the list,
			-- except if it was the last. Then determine the new last
			local found = false
			local last = nil
			for k in mail.pairsByKeys(maillists) do
				if found then
					mail.selected_idxs.owned_maillists[name] = k
					break
				elseif k == mail.selected_idxs.owned_maillists[name] then
					mail.delete_maillist(name, maillists[mail.selected_idxs.owned_maillists[name]].name)
					mail.selected_idxs.owned_maillists[name] = nil
					found = true
				else
					last = k
				end
			end
			if found and not mail.selected_idxs.owned_maillists[name] then
				-- was the last in the list, so take the previous (new last)
				mail.selected_idxs.owned_maillists[name] = last
			end
		end

		mail.show_maillists(name)

    elseif fields.mailliststab == "1" then
        mail.selected_idxs.mailliststab[name] = 1
        mail.show_owned_maillists(name)

    elseif fields.mailliststab == "2" then
        mail.selected_idxs.mailliststab[name] = 2
        mail.show_public_maillists(name)

	elseif fields.back then
		mail.show_mail_menu(name)
	end

	return true
end)
