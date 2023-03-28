
local inbox_formspec = "size[8,10;]" .. mail.theme .. [[
    tabheader[0.3,1;boxtab;Inbox,Sent messages;1;false;false]

    button[6,0.10;2,0.5;new;New]
    button[6,0.95;2,0.5;read;Read]
    button[6,1.70;2,0.5;reply;Reply]
    button[6,2.45;2,0.5;replyall;Reply All]
    button[6,3.20;2,0.5;forward;Forward]
    button[6,3.95;2,0.5;delete;Delete]
    button[6,4.82;2,0.5;markread;Mark Read]
    button[6,5.55;2,0.5;markunread;Mark Unread]
    button[6,6.8;2,0.5;contacts;Contacts]
    button[6,7.6;2,0.5;maillists;Mail lists]
    button[6,8.7;2,0.5;about;About]
    button_exit[6,9.5;2,0.5;quit;Close]

    tablecolumns[color;text;text]
    table[0,0.7;5.75,9.35;inbox;#999,From,Subject]]


function mail.show_inbox(name)
    local formspec = { inbox_formspec }
    local entry = mail.get_storage_entry(name)
    local messages = entry.inbox

    mail.message_drafts[name] = nil

    if messages[1] then
        for _, message in ipairs(messages) do
            if not message.read then
                if not mail.player_in_list(name, message.to) then
                    formspec[#formspec + 1] = ",#FFD788"
                else
                    formspec[#formspec + 1] = ",#FFD700"
                end
            else
                if not mail.player_in_list(name, message.to) then
                    formspec[#formspec + 1] = ",#CCCCDD"
                else
                    formspec[#formspec + 1] = ","
                end
            end
            formspec[#formspec + 1] = ","
            formspec[#formspec + 1] = minetest.formspec_escape(message.sender)
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
        if mail.selected_idxs.inbox[name] then
            formspec[#formspec + 1] = ";"
            formspec[#formspec + 1] = tostring(mail.selected_idxs.inbox[name] + 1)
        end
        formspec[#formspec + 1] = "]"
    else
        formspec[#formspec + 1] = "]label[2.25,4.5;No mail]"
    end
    minetest.show_formspec(name, "mail:inbox", table.concat(formspec, ""))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mail:inbox" and formname ~= "mail:sent" then
        return
    end

    local name = player:get_player_name()

    -- split inbox and sent msgs for different tests
    local entry = mail.get_storage_entry(name)

    local messagesInbox = entry.inbox
    local messagesSent = entry.outbox

    if fields.inbox then -- inbox table
        local evt = minetest.explode_table_event(fields.inbox)
        mail.selected_idxs.inbox[name] = evt.row - 1
        if evt.type == "DCL" and messagesInbox[mail.selected_idxs.inbox[name]] then
            mail.show_message(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        end
        return true
    end

    if fields.sent then -- sent table
        local evt = minetest.explode_table_event(fields.sent)
        mail.selected_idxs.sent[name] = evt.row - 1
        if evt.type == "DCL" and messagesSent[mail.selected_idxs.sent[name]] then
            mail.show_message(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end
        return true
    end

    if fields.boxtab == "1" then
        mail.selected_idxs.boxtab[name] = 1
        mail.show_inbox(name)

    elseif fields.boxtab == "2" then
        mail.selected_idxs.boxtab[name] = 1
        mail.show_sent(name)

    elseif fields.read then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then -- inbox table
            mail.show_message(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then -- sent table
            mail.show_message(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end

    elseif fields.delete then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then -- inbox table
            mail.delete_mail(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then -- sent table
            mail.delete_mail(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end

        mail.show_mail_menu(name)

    elseif fields.reply then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            local message = messagesInbox[mail.selected_idxs.inbox[name]]
            mail.reply(name, message)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            local message = messagesSent[mail.selected_idxs.sent[name]]
            mail.reply(name, message)
        end

    elseif fields.replyall then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            local message = messagesInbox[mail.selected_idxs.inbox[name]]
            mail.replyall(name, message)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            local message = messagesSent[mail.selected_idxs.sent[name]]
            mail.replyall(name, message)
        end

    elseif fields.forward then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            local message = messagesInbox[mail.selected_idxs.inbox[name]]
            mail.forward(name, message)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            local message = messagesSent[mail.selected_idxs.sent[name]]
            mail.forward(name, message)
        end

    elseif fields.markread then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            mail.mark_read(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            mail.mark_read(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end

        mail.show_mail_menu(name)

    elseif fields.markunread then
        if formname == "mail:inbox" and messagesInbox[mail.selected_idxs.inbox[name]] then
            mail.mark_unread(name, messagesInbox[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and messagesSent[mail.selected_idxs.sent[name]] then
            mail.mark_unread(name, messagesSent[mail.selected_idxs.sent[name]].id)
        end

        mail.show_mail_menu(name)

    elseif fields.new then
        mail.show_compose(name)

    elseif fields.contacts then
        mail.show_contacts(name)

    elseif fields.maillists then
        mail.show_maillists(name)

    elseif fields.about then
        mail.show_about(name)

    end

    return true
end)