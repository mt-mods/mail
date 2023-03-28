
local sent_formspec = "size[8,10;]" .. mail.theme .. [[
    tabheader[0.3,1;boxtab;Inbox,Sent messages;2;false;false]

    button[6,0.10;2,0.5;new;New]
    button[6,0.95;2,0.5;read;Read]
    button[6,1.70;2,0.5;reply;Reply]
    button[6,2.45;2,0.5;replyall;Reply All]
    button[6,3.20;2,0.5;forward;Forward]
    button[6,3.95;2,0.5;delete;Delete]
    button[6,6.8;2,0.5;contacts;Contacts]
    button[6,7.6;2,0.5;maillists;Mail lists]
    button[6,8.7;2,0.5;about;About]
    button_exit[6,9.5;2,0.5;quit;Close]

    tablecolumns[color;text;text]
    table[0,0.7;5.75,9.35;sent;#999,To,Subject]]


function mail.show_sent(name)
	local formspec = { sent_formspec }
	local messages = mail.getPlayerSentMessages(name)

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
				formspec[#formspec + 1] = "(No subject)"
			end
		end
		if mail.selected_idxs.sent[name] then
			formspec[#formspec + 1] = ";"
			formspec[#formspec + 1] = tostring(mail.selected_idxs.sent[name] + 1)
		end
		formspec[#formspec + 1] = "]"
	else
		formspec[#formspec + 1] = "]label[2.25,4.5;No mail]"
	end
	minetest.show_formspec(name, "mail:sent", table.concat(formspec, ""))
end
