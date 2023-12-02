-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:receivers"

function mail.show_receivers(name, id)
	local message = mail.get_message(name, id)

	local formspec = [[
			size[8,6]

			box[0,0;7,1.1;]] .. mail.get_color("highlighted") .. [[]

			button[7.25,0.15;0.75,0.5;back;X]

			label[0.2,0.1;]] .. S("From") .. [[: %s]
			label[0.2,0.5;]] .. S("Date") .. [[: %s]

			tablecolumns[color;text]
			table[0,1.5;3.8,4.5;to;%s]

			tablecolumns[color;text]
			table[4,1.5;3.8,4.5;cc;%s]
		]] .. mail.theme

	local from = minetest.formspec_escape(message.from) or ""
	local to = mail.parse_player_list(message.to or "")
	local to_str = mail.get_color("header") .. "," .. S("To") .. ",,"
	to_str = to_str .. table.concat(to, ",,")
	local cc = mail.parse_player_list(message.cc or "")
	local cc_str = mail.get_color("header") .. "," .. S("CC") .. ",,"
	cc_str = cc_str .. table.concat(cc, ",,")
	local date = type(message.time) == "number"
		and minetest.formspec_escape(os.date(mail.get_setting(name, "date_format"), message.time)) or ""
	formspec = string.format(formspec, from, date, to_str, cc_str)

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()

	local message_id = mail.selected_idxs.message[name]

	if fields.back then
		mail.show_message(name, message_id)
	end

	return true
end)
