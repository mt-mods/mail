local FORMNAME = "mail:editmaillist"

function mail.show_edit_maillist(playername, maillist_name, desc, players, illegal_name_hint)
	local formspec = [[
			size[6,7]
			button[4,6.25;2,0.5;back;Back]
			field[0.25,0.5;4,1;name;Maillist name:;%s]
			textarea[0.25,1.6;4,2;desc;Desc:;%s]
			textarea[0.25,3.6;4,4.25;players;Players:;%s]
			button[4,0.10;2,1;save;Save]
		]]
	if illegal_name_hint == "collision" then
		formspec = formspec .. [[
				label[4,1;That name]
				label[4,1.5;is already in]
				label[4,2;your maillists.]
			]]
	elseif illegal_name_hint == "empty" then
		formspec = formspec .. [[
				label[4,1;The maillist]
				label[4,1.5;name cannot]
				label[4,2;be empty.]
			]]
	end
	formspec = formspec .. mail.theme
	formspec = string.format(formspec,
		minetest.formspec_escape(maillist_name or ""),
		minetest.formspec_escape(desc or ""),
		minetest.formspec_escape(players or ""))
	minetest.show_formspec(playername, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()
	local maillists = mail.getPlayerMaillists(name)

	if fields.save then
		local maillist = {
			owner = name,
			name = fields.name,
			desc = fields.desc,
		}
		if mail.selected_idxs.maillists[name] and mail.selected_idxs.maillists[name] ~= "#NEW#" then
			mail.setMaillist(maillists[mail.selected_idxs.maillists[name]].id, maillist, fields.players)
		else
			mail.addMaillist(maillist, fields.players)
		end
		mail.show_maillists(name)

	elseif fields.back then
		mail.show_maillists(name)
	end

	return true
end)