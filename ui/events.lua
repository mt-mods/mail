
-- Getter to filter and sort messages on demand
local function messageGetter(messages, sortfield, ascending, filter)
    local results
    return function()
        if not results then
            results = mail.sort_messages(messages, sortfield, ascending, filter)
        end
        return results
    end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mail:inbox" and formname ~= "mail:sent" and formname ~= "mail:drafts" then
        return
    end

    -- Get player name and handle / convert common input fields
    local name = player:get_player_name()
    local filter = fields.filter or ""
    local sortfieldindex = tonumber(fields.sortfield or mail.selected_idxs.sortfield[name]) or 3
    local sortdirection = fields.sortdirection or mail.selected_idxs.sortdirection[name] or "1"
    local inboxsortfield = ({"from","subject","time"})[sortfieldindex]
    local outboxsortfield = ({"to","subject","time"})[sortfieldindex]

    -- Store common player configuration for reuse
    mail.selected_idxs.sortfield[name] = sortfieldindex
    mail.selected_idxs.sortdirection[name] = sortdirection

    -- split inbox and sent msgs for different tests
    local entry = mail.get_storage_entry(name)
    local messagesDrafts = entry.drafts
    local getInbox = messageGetter(entry.inbox, inboxsortfield, sortdirection == "2", filter)
    local getOutbox = messageGetter(entry.outbox, outboxsortfield, sortdirection == "2", filter)

    -- Hanmdle formspec event
    if fields.inbox then -- inbox table
        local evt = minetest.explode_table_event(fields.inbox)
        mail.selected_idxs.inbox[name] = evt.row - 1
        if evt.type == "DCL" and getInbox()[mail.selected_idxs.inbox[name]] then
            mail.show_message(name, getInbox()[mail.selected_idxs.inbox[name]].id)
        end
        return true
    end

    if fields.sent then -- sent table
        local evt = minetest.explode_table_event(fields.sent)
        mail.selected_idxs.sent[name] = evt.row - 1
        if evt.type == "DCL" and getOutbox()[mail.selected_idxs.sent[name]] then
            mail.show_message(name, getOutbox()[mail.selected_idxs.sent[name]].id)
        end
        return true
    end

    if fields.drafts then -- drafts table
        local evt = minetest.explode_table_event(fields.drafts)
        mail.selected_idxs.drafts[name] = evt.row - 1
        if evt.type == "DCL" and messagesDrafts[mail.selected_idxs.drafts[name]] then
            mail.show_compose(name,
            messagesDrafts[mail.selected_idxs.drafts[name]].to,
            messagesDrafts[mail.selected_idxs.drafts[name]].subject,
            messagesDrafts[mail.selected_idxs.drafts[name]].body,
            messagesDrafts[mail.selected_idxs.drafts[name]].cc,
            messagesDrafts[mail.selected_idxs.drafts[name]].bcc,
            messagesDrafts[mail.selected_idxs.drafts[name]].id
            )
        end
        return true
    end

    if fields.boxtab == "1" then
        mail.selected_idxs.boxtab[name] = 1
        mail.show_inbox(name, sortfieldindex, sortdirection, filter)

    elseif fields.boxtab == "2" then
        mail.selected_idxs.boxtab[name] = 2
        mail.show_sent(name, sortfieldindex, sortdirection, filter)

    elseif fields.boxtab == "3" then
        mail.selected_idxs.boxtab[name] = 3
        mail.show_drafts(name)

    elseif fields.read then
        if formname == "mail:inbox" and getInbox()[mail.selected_idxs.inbox[name]] then -- inbox table
            mail.show_message(name, getInbox()[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and getOutbox()[mail.selected_idxs.sent[name]] then -- sent table
            mail.show_message(name, getOutbox()[mail.selected_idxs.sent[name]].id)
        end

    elseif fields.edit then
        if formname == "mail:drafts" and messagesDrafts[mail.selected_idxs.drafts[name]] then
            mail.show_compose(name,
            messagesDrafts[mail.selected_idxs.drafts[name]].to,
            messagesDrafts[mail.selected_idxs.drafts[name]].subject,
            messagesDrafts[mail.selected_idxs.drafts[name]].body,
            messagesDrafts[mail.selected_idxs.drafts[name]].cc,
            messagesDrafts[mail.selected_idxs.drafts[name]].bcc,
            messagesDrafts[mail.selected_idxs.drafts[name]].id
            )
        end

    elseif fields.delete then
        if formname == "mail:inbox" and getInbox()[mail.selected_idxs.inbox[name]] then -- inbox table
            mail.delete_mail(name, getInbox()[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and getOutbox()[mail.selected_idxs.sent[name]] then -- sent table
            mail.delete_mail(name, getOutbox()[mail.selected_idxs.sent[name]].id)
        elseif formname == "mail:drafts" and messagesDrafts[mail.selected_idxs.drafts[name]] then -- drafts table
            mail.delete_mail(name, messagesDrafts[mail.selected_idxs.drafts[name]].id)
        end

        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.reply then
        if formname == "mail:inbox" and getInbox()[mail.selected_idxs.inbox[name]] then
            local message = getInbox()[mail.selected_idxs.inbox[name]]
            mail.reply(name, message)
        elseif formname == "mail:sent" and getOutbox()[mail.selected_idxs.sent[name]] then
            local message = getOutbox()[mail.selected_idxs.sent[name]]
            mail.reply(name, message)
        end

    elseif fields.replyall then
        if formname == "mail:inbox" and getInbox()[mail.selected_idxs.inbox[name]] then
            local message = getInbox()[mail.selected_idxs.inbox[name]]
            mail.replyall(name, message)
        elseif formname == "mail:sent" and getOutbox()[mail.selected_idxs.sent[name]] then
            local message = getOutbox()[mail.selected_idxs.sent[name]]
            mail.replyall(name, message)
        end

    elseif fields.forward then
        if formname == "mail:inbox" and getInbox()[mail.selected_idxs.inbox[name]] then
            local message = getInbox()[mail.selected_idxs.inbox[name]]
            mail.forward(name, message)
        elseif formname == "mail:sent" and getOutbox()[mail.selected_idxs.sent[name]] then
            local message = getOutbox()[mail.selected_idxs.sent[name]]
            mail.forward(name, message)
        end

    elseif fields.markread then
        if formname == "mail:inbox" and getInbox()[mail.selected_idxs.inbox[name]] then
            mail.mark_read(name, getInbox()[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and getOutbox()[mail.selected_idxs.sent[name]] then
            mail.mark_read(name, getOutbox()[mail.selected_idxs.sent[name]].id)
        end

        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.markunread then
        if formname == "mail:inbox" and getInbox()[mail.selected_idxs.inbox[name]] then
            mail.mark_unread(name, getInbox()[mail.selected_idxs.inbox[name]].id)
        elseif formname == "mail:sent" and getOutbox()[mail.selected_idxs.sent[name]] then
            mail.mark_unread(name, getOutbox()[mail.selected_idxs.sent[name]].id)
        end

        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.new then
        mail.show_compose(name)

    elseif fields.contacts then
        mail.show_contacts(name)

    elseif fields.maillists then
        mail.show_maillists(name)

    elseif fields.about then
        mail.show_about(name)

    elseif fields.sortfield or fields.sortdirection or fields.filter then
        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)
    end

    return true
end)
