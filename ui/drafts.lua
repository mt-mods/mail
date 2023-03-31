-- translation
local S = minetest.get_translator("mail")

local drafts_formspec = "size[8.5,10;]" .. mail.theme .. [[
    tabheader[0.3,1;boxtab;]] .. S("Inbox") .. "," .. S("Sent messages").. "," .. S("Drafts") .. [[;3;false;false]

    button[6,0.10;2.5,0.5;new;]] .. S("New") .. [[]
    button[6,0.95;2.5,0.5;edit;]] .. S("Edit") .. [[]
    button[6,1.70;2.5,0.5;delete;]] .. S("Delete") .. [[]
    button[6,6.8;2.5,0.5;contacts;]] .. S("Contacts") .. [[]
    button[6,7.6;2.5,0.5;maillists;]] .. S("Mail lists") .. [[]
    button[6,8.7;2.5,0.5;about;]] .. S("About") .. [[]
    button_exit[6,9.5;2.5,0.5;quit;]] .. S("Close") .. [[]

    tablecolumns[color;text;text]
    table[0,0.7;5.75,9.35;drafts;#999,]] .. S("To") .. "," .. S("Subject")


function mail.show_drafts(name)
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
		if mail.selected_idxs.sent[name] then
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = tostring(mail.selected_idxs.sent[name] + 1)
		end
		formspec[#formspec + 1] = "]"
	else
		formspec[#formspec + 1] = "]label[2.25,4.5;" .. S("No drafts") .. "]"
	end
    minetest.show_formspec(name, "mail:drafts", table.concat(formspec, ""))
end
