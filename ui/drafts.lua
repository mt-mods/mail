-- translation
local S = minetest.get_translator("mail")


function mail.show_drafts(name)
	local trash_tab = ""
	if mail.get_setting(name, "trash_move_enable") then
		trash_tab = "," .. S("Trash")
	end

	local drafts_formspec = "size[8.5,11;]" .. mail.theme .. [[
		tabheader[0.3,1;boxtab;]] ..
		S("Inbox") .. "," .. S("Outbox").. "," .. S("Drafts") .. trash_tab .. [[;3;false;false]

		button[6,0.10;2.5,0.5;new;]] .. S("New") .. [[]
		button[6,0.95;2.5,0.5;edit;]] .. S("Edit") .. [[]
		button[6,1.70;2.5,0.5;delete;]] .. S("Delete") .. [[]
		button[6,8.0;2.5,0.5;contacts;]] .. S("Contacts") .. [[]
		button[6,8.8;2.5,0.5;maillists;]] .. S("Mail lists") .. [[]
		button[6,9.7;2.5,0.5;options;]] .. S("Options") .. [[]
		button_exit[6,10.5;2.5,0.5;quit;]] .. S("Close") .. [[]

		tablecolumns[color;text;text]
		table[0,0.7;5.75,10.35;drafts;]] .. mail.get_color("header") .. "," .. S("To") .. "," .. S("Subject")

    local formspec = { drafts_formspec }
    local entry = mail.get_storage_entry(name)
    local messages = entry.drafts

    mail.message_drafts[name] = nil

    if messages[1] then
		for _, message in ipairs(messages) do
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = minetest.formspec_escape(message.to)
			formspec[#formspec + 1] = ","
			if message.subject ~= "" then
				if string.len(message.subject) > 30 then
					formspec[#formspec + 1] = minetest.formspec_escape(string.sub(message.subject, 1, 27))
					formspec[#formspec + 1] = "..."
				else
					formspec[#formspec + 1] = minetest.formspec_escape(message.subject)
				end
			else
				formspec[#formspec + 1] = S("(No subject)")
			end
		end
		if mail.selected_idxs.drafts[name] then
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = tostring(mail.selected_idxs.drafts[name] + 1)
		end
		formspec[#formspec + 1] = "]"
	else
		formspec[#formspec + 1] = "]label[2.25,4.5;" .. S("No drafts") .. "]"
	end
    minetest.show_formspec(name, "mail:drafts", table.concat(formspec, ""))
end
