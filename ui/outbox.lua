-- translation
local S = minetest.get_translator("mail")

function mail.show_outbox(name, sortfieldindex, sortdirection, filter)
    sortfieldindex = tonumber(sortfieldindex or mail.selected_idxs.sortfield[name])
    or mail.get_setting(name, "defaultsortfield") or 3
    sortdirection = tostring(sortdirection or mail.selected_idxs.sortdirection[name]
    or mail.get_setting(name, "defaultsortdirection") or "1")
	filter = filter or mail.selected_idxs.filter[name] or ""
    mail.selected_idxs.outbox[name] = mail.selected_idxs.outbox[name] or {}

	local entry = mail.get_storage_entry(name)
	local sortfield = ({"to","subject","time"})[sortfieldindex]
    local messages = mail.sort_messages(entry.outbox, sortfield, sortdirection == "2", filter)

    if mail.selected_idxs.outbox[name] and #mail.selected_idxs.outbox[name] > 0 then
        for i, selected_msg in ipairs(mail.selected_idxs.outbox[name]) do
            local is_present = false
            for _, msg in ipairs(messages) do
                if msg.id == selected_msg then
                    is_present = true
                    break
                end
            end
            if not is_present then
                table.remove(mail.selected_idxs.outbox[name], i)
            end
        end
    end

    local trash_tab = ""
    if mail.get_setting(name, "trash_move_enable") then
        trash_tab = "," .. S("Trash")
    end

	local outbox_formspec = "size[8.5,11;]" .. mail.theme .. [[
		tabheader[0.3,1;boxtab;]] ..
		S("Inbox") .. "," .. S("Outbox").. "," .. S("Drafts") .. trash_tab .. [[;2;false;false]

		button[6,0.10;2.5,0.5;new;]] .. S("New") .. [[]
		button[6,0.95;2.5,0.5;read;]] .. S("Read") .. [[]
		button[6,1.70;2.5,0.5;reply;]] .. S("Reply") .. [[]
		button[6,2.45;2.5,0.5;replyall;]] .. S("Reply all") .. [[]
		button[6,3.20;2.5,0.5;forward;]] .. S("Forward") .. [[]
		button[6,3.95;2.5,0.5;delete;]] .. S("Delete") .. [[]
		button[6,8.0;2.5,0.5;contacts;]] .. S("Contacts") .. [[]
		button[6,8.8;2.5,0.5;maillists;]] .. S("Mail lists") .. [[]
        button[6,9.7;2.5,0.5;options;]] .. S("Options") .. [[]
		button_exit[6,10.5;2.5,0.5;quit;]] .. S("Close") .. [[]

        tooltip[reply;]] .. S("Reply only to the sender") .. [[]
        tooltip[replyall;]] .. S("Reply to all involved people") .. [[]
        tooltip[forward;]] .. S("Transfer message to other people") .. [[]

        dropdown[0,9.5;2,0.5;sortfield;]] ..
        S("To") .. "," .. S("Subject") .. "," .. S("Date") .. [[;]] .. sortfieldindex .. [[;true]
        dropdown[2.0,9.5;2,0.5;sortdirection;]] ..
        S("Ascending") .. "," .. S("Descending") .. [[;]] .. sortdirection .. [[;true]
        field[4.25,9.95;1.4,0.5;filter;]] .. S("Filter") .. [[:;]] .. filter .. [[]
        button[5.14,9.62;0.85,0.5;search;Q]

        checkbox[0,10.1;multipleselection;]] .. S("Allow multiple selection") .. [[;]] ..
        tostring(mail.selected_idxs.multipleselection[name]) .. [[]
        label[0,10.65;]] ..
        S("@1 of @2 selected", tostring(#mail.selected_idxs.outbox[name]), tostring(#messages)) .. [[]
        button[3.5,10.5;2.5,0.5;selectall;]] .. S("(Un)select all") .. [[]

		tablecolumns[color;text;text]
        table[0,0.7;5.75,8.45;outbox;]] .. mail.get_color("header") .. "," .. S("To") .. "," .. S("Subject")
	local formspec = { outbox_formspec }

	mail.message_drafts[name] = nil

	if #messages > 0 then
        for _, message in ipairs(messages) do
            local selected_id = 0
            local displayed_color = {}
            -- check if message is in selection list and return its id
            if mail.selected_idxs.outbox[name] and #mail.selected_idxs.outbox[name] > 0 then
                for i, selected_msg in ipairs(mail.selected_idxs.outbox[name]) do
                    if message.id == selected_msg then
                        selected_id = i
                        break
                    end
                end
            end
            if selected_id > 0 then
                table.insert(displayed_color, "selected")
            end
            formspec[#formspec + 1] = "," .. mail.get_color(displayed_color)
            formspec[#formspec + 1] = ","
			if string.len(message.to) > 20 then
				formspec[#formspec + 1] = minetest.formspec_escape(string.sub(message.to, 1, 17))
				formspec[#formspec + 1] = "..."
			else
				formspec[#formspec + 1] = minetest.formspec_escape(message.to)
			end
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
        formspec[#formspec + 1] = "]"
    else
        formspec[#formspec + 1] = "]label[2.25,4.5;" .. S("No mail") .. "]"
    end

	minetest.show_formspec(name, "mail:outbox", table.concat(formspec, ""))
end
