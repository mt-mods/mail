local FORMNAME = "mail:compose"

function mail.show_compose(name, to, subject, body, cc, bcc)
	local formspec = [[
			size[8,9]
			button[0,0;1,1;tocontacts;]] .. S("To") .. [[:]
			field[1.1,0.3;3.2,1;to;;%s]
			button[4,0;1,1;cccontacts;]] .. S("CC") .. [[:]
			field[5.1,0.3;3.1,1;cc;;%s]
			button[4,0.75;1,1;bcccontacts;]] .. S("BCC") .. [[:]
			field[5.1,1.05;3.1,1;bcc;;%s]
			field[0.25,2;8,1;subject;]] .. S("Subject") .. [[:;%s]
			textarea[0.25,2.5;8,6;body;;%s]
			button[0.5,8.5;3,1;cancel;]] .. S("Cancel") .. [[]
			button[4.5,8.5;3,1;send;]] .. S("Send") .. [[]
		]] .. mail.theme

	formspec = string.format(formspec,
		minetest.formspec_escape(to or ""),
		minetest.formspec_escape(cc or ""),
		minetest.formspec_escape(bcc or ""),
		minetest.formspec_escape(subject or ""),
		minetest.formspec_escape(body or ""))

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()
    if fields.send then
        local success, err = mail.send({
            from = name,
            to = fields.to,
            cc = fields.cc,
            bcc = fields.bcc,
            subject = fields.subject,
            body = fields.body,
        })
        if not success then
            minetest.chat_send_player(name, err)
            return
        end

        -- add new contacts if some receivers aren't registered
        local contacts = mail.get_contacts(name)
        local recipients = mail.parse_player_list(fields.to)
        local isNew = true
        for _,recipient in ipairs(recipients) do
            if recipient:sub(1,1) == "@" then -- in case of maillist -- check if first char is @
                isNew = false
            else
                for _,contact in ipairs(contacts) do
                    if contact.name == recipient then
                        isNew = false
                        break
                    end
                end
            end
            if isNew then
                mail.update_contact(name, {name = recipient, note = ""})
            end
        end

        minetest.after(0.5, function()
            mail.show_mail_menu(name)
        end)

    elseif fields.tocontacts or fields.cccontacts or fields.bcccontacts then
        mail.message_drafts[name] = {
            to = fields.to,
            cc = fields.cc,
            bcc = fields.bcc,
            subject = fields.subject,
            body = fields.body,
        }
        mail.show_select_contact(name, fields.to, fields.cc, fields.bcc)

    elseif fields.cancel then
        mail.message_drafts[name] = nil

        mail.show_mail_menu(name)
    end

    return true
end)
