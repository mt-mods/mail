-- translation
local S = minetest.get_translator("mail")


function mail.show_sent(name, sortfield, sortdirection, filter)
    if not sortfield or sortfield == "" or sortfield == "0" then
        sortfield = 3
    end
    if not sortdirection or sortdirection == "" or sortdirection == "0" then
        sortdirection = 1
    end

    if not filter then
        filter = ""
    end

	local sent_formspec = "size[8.5,10;]" .. mail.theme .. [[
		tabheader[0.3,1;boxtab;]] .. S("Inbox") .. "," .. S("Sent messages").. "," .. S("Drafts") .. [[;2;false;false]

		button[6,0.10;2.5,0.5;new;]] .. S("New") .. [[]
		button[6,0.95;2.5,0.5;read;]] .. S("Read") .. [[]
		button[6,1.70;2.5,0.5;reply;]] .. S("Reply") .. [[]
		button[6,2.45;2.5,0.5;replyall;]] .. S("Reply all") .. [[]
		button[6,3.20;2.5,0.5;forward;]] .. S("Forward") .. [[]
		button[6,3.95;2.5,0.5;delete;]] .. S("Delete") .. [[]
		button[6,6.8;2.5,0.5;contacts;]] .. S("Contacts") .. [[]
		button[6,7.6;2.5,0.5;maillists;]] .. S("Mail lists") .. [[]
		button[6,8.7;2.5,0.5;about;]] .. S("About") .. [[]
		button_exit[6,9.5;2.5,0.5;quit;]] .. S("Close") .. [[]

        dropdown[0,9.4;2,0.5;sortfield;]] .. S("To") .. "," .. S("Subject") .. "," .. S("Date") .. [[;]] .. tostring(sortfield) .. [[;1]
        dropdown[2.0,9.4;2,0.5;sortdirection;]] .. S("Ascending") .. "," .. S("Descending") .. [[;]] .. tostring(sortdirection) .. [[;1]
        field[4.25,9.85;1.4,0.5;filter;]] .. S("Filter") .. [[:;]] .. filter .. [[]
        button[5.14,9.52;0.85,0.5;search;Q]

		tablecolumns[color;text;text]
		table[0,0.7;5.75,8.35;sent;#999,]] .. S("To") .. "," .. S("Subject")
	local formspec = { sent_formspec }
	local entry = mail.get_storage_entry(name)
    local messages = mail.sort_messages(mail.filter_messages(entry.outbox, filter), tostring(sortfield), tostring(sortdirection))

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
		formspec[#formspec + 1] = "]label[2.25,4.5;" .. S("No mail") .. "]"
	end
	minetest.show_formspec(name, "mail:sent", table.concat(formspec, ""))
end
