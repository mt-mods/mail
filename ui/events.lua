
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

local function nonempty(x)
 return ((type(x)=="table")and(#x>0))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "mail:inbox" and formname ~= "mail:outbox"
    and formname ~= "mail:drafts" and formname ~= "mail:trash" then
        return
    end

    if fields.quit then
        return true
    end

    -- Get player name and handle / convert common input fields
    local name = player:get_player_name()
    local filter = (fields.search and fields.filter) or mail.selected_idxs.filter[name] or ""
    local sortfieldindex = tonumber(fields.sortfield or mail.selected_idxs.sortfield[name]) or 3
    local sortdirection = fields.sortdirection or mail.selected_idxs.sortdirection[name] or "1"
    local inboxsortfield = ({"from","subject","time"})[sortfieldindex]
    local outboxsortfield = ({"to","subject","time"})[sortfieldindex]

    -- Be sure that inbox/outbox selected idxs aren't nil
    mail.selected_idxs.inbox[name] = mail.selected_idxs.inbox[name] or {}
    mail.selected_idxs.outbox[name] = mail.selected_idxs.outbox[name] or {}

    -- Store common player configuration for reuse
    mail.selected_idxs.sortfield[name] = sortfieldindex
    mail.selected_idxs.sortdirection[name] = sortdirection
    mail.selected_idxs.filter[name] = filter
    if fields.multipleselection then
        mail.selected_idxs.multipleselection[name] = fields.multipleselection == "true"
    end

    -- Avoid several selected after disabling the multiple selection
    if not mail.selected_idxs.multipleselection[name] then
        mail.selected_idxs.inbox[name] = { mail.selected_idxs.inbox[name][#mail.selected_idxs.inbox[name]] }
        mail.selected_idxs.outbox[name] = { mail.selected_idxs.outbox[name][#mail.selected_idxs.outbox[name]] }
    end

    -- split inbox and outbox msgs for different tests
    local entry = mail.get_storage_entry(name)
    local messagesDrafts = entry.drafts
    local messagesTrash = entry.trash
    local getInbox = messageGetter(entry.inbox, inboxsortfield, sortdirection == "2", filter)
    local getOutbox = messageGetter(entry.outbox, outboxsortfield, sortdirection == "2", filter)

    -- Hanmdle formspec event
    if fields.inbox then -- inbox table
        local evt = minetest.explode_table_event(fields.inbox)
        if evt.row == 1 then -- header
            if mail.selected_idxs.sortfield[name] == evt.column-1 then -- if already this field, then change direction
                mail.selected_idxs.sortdirection[name] = mail.selected_idxs.sortdirection[name] == "2" and "1" or "2"
            end
            mail.selected_idxs.sortfield[name] = evt.column-1 -- update column
            mail.show_mail_menu(name)
            return true
        end
        local inbox = getInbox()[evt.row-1]
        if not inbox then
            mail.show_mail_menu(name)
            return true
        end
        if mail.selected_idxs.multipleselection[name] then
            if not mail.selected_idxs.inbox[name] then
                mail.selected_idxs.inbox[name] = {}
            end
            local selected_id = 0
            if mail.selected_idxs.inbox[name] and #mail.selected_idxs.inbox[name] > 0 then
                for i, selected_msg in ipairs(mail.selected_idxs.inbox[name]) do
                    if inbox.id == selected_msg then
                        selected_id = i
                        table.remove(mail.selected_idxs.inbox[name], i)
                        break
                    end
                end
            end
            if selected_id == 0 then
                table.insert(mail.selected_idxs.inbox[name], inbox.id)
                mail.selected_idxs.message[name] = inbox.id
            end
        else
            mail.selected_idxs.inbox[name] = { inbox.id }
            mail.selected_idxs.message[name] = inbox.id
        end
        if evt.type == "DCL" then
            mail.selected_idxs.message[name] = inbox.id
            mail.show_message(name, inbox.id)
        else
            mail.show_mail_menu(name)
        end
        return true
    end

    if fields.outbox then -- outbox table
        local evt = minetest.explode_table_event(fields.outbox)
        if evt.row == 1 then -- header
            if mail.selected_idxs.sortfield[name] == evt.column-1 then -- if already this field, then change direction
                mail.selected_idxs.sortdirection[name] = mail.selected_idxs.sortdirection[name] == "2" and "1" or "2"
            end
            mail.selected_idxs.sortfield[name] = evt.column-1 -- update column
            mail.show_mail_menu(name)
            return true
        end
        local outbox = getOutbox()[evt.row-1]
        if not outbox then
            mail.show_mail_menu(name)
            return true
        end
        if mail.selected_idxs.multipleselection[name] then
            if not mail.selected_idxs.outbox[name] then
                mail.selected_idxs.outbox[name] = {}
            end
            local selected_id = 0
            if mail.selected_idxs.outbox[name] and #mail.selected_idxs.outbox[name] > 0 then
                for i, selected_msg in ipairs(mail.selected_idxs.outbox[name]) do
                    if outbox.id == selected_msg then
                        selected_id = i
                        table.remove(mail.selected_idxs.outbox[name], i)
                        break
                    end
                end
            end
            if selected_id == 0 then
                table.insert(mail.selected_idxs.outbox[name], outbox.id)
                mail.selected_idxs.message[name] = outbox.id
            end
        else
            mail.selected_idxs.outbox[name] = { outbox.id }
            mail.selected_idxs.message[name] = outbox.id
        end
        if evt.type == "DCL" then
            mail.selected_idxs.message[name] = outbox.id
            mail.show_message(name, outbox.id)
        else
            mail.show_mail_menu(name)
        end
        return true
    end

    if fields.drafts then -- drafts table
        local evt = minetest.explode_table_event(fields.drafts)
        if evt.row == 1 then -- header
            if mail.selected_idxs.sortfield[name] == evt.column-1 then -- if already this field, then change direction
                mail.selected_idxs.sortdirection[name] = mail.selected_idxs.sortdirection[name] == "2" and "1" or "2"
            end
            mail.selected_idxs.sortfield[name] = evt.column-1 -- update column
            mail.show_mail_menu(name)
            return
        end
        mail.selected_idxs.drafts[name] = evt.row - 1
        if evt.type == "DCL" and messagesDrafts[mail.selected_idxs.drafts[name]] then
            mail.selected_idxs.message[name] = messagesDrafts[mail.selected_idxs.drafts[name]].id
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

    if fields.trash then -- trash table
        local evt = minetest.explode_table_event(fields.trash)
        if evt.row == 1 then -- header
            if mail.selected_idxs.sortfield[name] == evt.column-1 then -- if already this field, then change direction
                mail.selected_idxs.sortdirection[name] = mail.selected_idxs.sortdirection[name] == "2" and "1" or "2"
            end
            mail.selected_idxs.sortfield[name] = evt.column-1 -- update column
            mail.show_mail_menu(name)
            return
        end
        mail.selected_idxs.trash[name] = evt.row - 1
        if evt.type == "DCL" and messagesTrash[mail.selected_idxs.trash[name]] then
            mail.selected_idxs.message[name] = messagesTrash[mail.selected_idxs.trash[name]].id
            mail.show_message(name, messagesTrash[mail.selected_idxs.trash[name]].id)
        end
        return true
    end

    if fields.boxtab == "1" then
        mail.selected_idxs.boxtab[name] = 1
        mail.show_inbox(name, sortfieldindex, sortdirection, filter)

    elseif fields.boxtab == "2" then
        mail.selected_idxs.boxtab[name] = 2
        mail.show_outbox(name, sortfieldindex, sortdirection, filter)

    elseif fields.boxtab == "3" then
        mail.selected_idxs.boxtab[name] = 3
        mail.show_drafts(name)

    elseif fields.boxtab == "4" then
        mail.selected_idxs.boxtab[name] = 4
        mail.show_trash(name)

    elseif fields.read then
        if formname == "mail:inbox" and nonempty(mail.selected_idxs.inbox[name]) then -- inbox table
            mail.selected_idxs.message[name] = mail.selected_idxs.inbox[name][#mail.selected_idxs.inbox[name]]
        elseif formname == "mail:outbox" and nonempty(mail.selected_idxs.outbox[name]) then -- outbox table
            mail.selected_idxs.message[name] = mail.selected_idxs.outbox[name][#mail.selected_idxs.outbox[name]]
        elseif formname == "mail:trash" and messagesTrash[mail.selected_idxs.trash[name]] then
            mail.selected_idxs.message[name] = messagesTrash[mail.selected_idxs.trash[name]].id
        end
        if mail.selected_idxs.message[name] then
            mail.show_message(name, mail.selected_idxs.message[name])
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
        local trash_enabled = mail.get_setting(name, "trash_move_enable")
        if formname == "mail:inbox" and mail.selected_idxs.inbox[name] then -- inbox table
            if trash_enabled then
                mail.trash_mail(name, mail.selected_idxs.inbox[name])
            else
                mail.delete_mail(name, mail.selected_idxs.inbox[name])
            end
            mail.selected_idxs.inbox[name] = {}
        elseif formname == "mail:outbox" and mail.selected_idxs.outbox[name] then -- outbox table
            if trash_enabled then
                mail.trash_mail(name, mail.selected_idxs.outbox[name])
            else
                mail.delete_mail(name, mail.selected_idxs.outbox[name])
            end
            mail.selected_idxs.outbox[name] = {}
        elseif formname == "mail:drafts" and messagesDrafts[mail.selected_idxs.drafts[name]] then -- drafts table
            if trash_enabled then
                mail.trash_mail(name, messagesDrafts[mail.selected_idxs.drafts[name]].id)
            else
                mail.delete_mail(name, messagesDrafts[mail.selected_idxs.drafts[name]].id)
            end
            mail.selected_idxs.drafts[name] = nil

        elseif formname == "mail:trash" and messagesTrash[mail.selected_idxs.trash[name]] then -- trash table
            mail.delete_mail(name, messagesTrash[mail.selected_idxs.trash[name]].id, true)
        end

        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.restore then
        if messagesTrash[mail.selected_idxs.trash[name]] then
            mail.restore_mail(name, messagesTrash[mail.selected_idxs.trash[name]].id)
        end
        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.reply then
        if formname == "mail:inbox" and mail.selected_idxs.inbox[name] and #mail.selected_idxs.inbox[name] > 0 then
            local message = mail.get_message(name, mail.selected_idxs.inbox[name][#mail.selected_idxs.inbox[name]])
            mail.reply(name, message)
        elseif
        formname == "mail:outbox" and mail.selected_idxs.outbox[name] and #mail.selected_idxs.outbox[name] > 0 then
            local message = mail.get_message(name, mail.selected_idxs.outbox[name][#mail.selected_idxs.outbox[name]])
            mail.reply(name, message)
        end

    elseif fields.replyall then
        if formname == "mail:inbox" and mail.selected_idxs.inbox[name] and #mail.selected_idxs.inbox[name] > 0 then
            local message = mail.get_message(name, mail.selected_idxs.inbox[name][#mail.selected_idxs.inbox[name]])
            mail.replyall(name, message)
        elseif
        formname == "mail:outbox" and mail.selected_idxs.outbox[name] and #mail.selected_idxs.outbox[name] > 0 then
            local message = mail.get_message(name, mail.selected_idxs.outbox[name][#mail.selected_idxs.outbox[name]])
            mail.replyall(name, message)
        end

    elseif fields.forward then
        if formname == "mail:inbox" and mail.selected_idxs.inbox[name] and #mail.selected_idxs.inbox[name] > 0 then
            local message = mail.get_message(name, mail.selected_idxs.inbox[name][#mail.selected_idxs.inbox[name]])
            mail.forward(name, message)
        elseif
        formname == "mail:outbox" and mail.selected_idxs.outbox[name] and #mail.selected_idxs.outbox[name] > 0 then
            local message = mail.get_message(name, mail.selected_idxs.outbox[name][#mail.selected_idxs.outbox[name]])
            mail.forward(name, message)
        end

    elseif fields.markread then
        if formname == "mail:inbox" and mail.selected_idxs.inbox[name] then
            mail.mark_read(name, mail.selected_idxs.inbox[name])
        end

        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.markunread then
        if formname == "mail:inbox" and mail.selected_idxs.inbox[name] then
            mail.mark_unread(name, mail.selected_idxs.inbox[name])
        end

        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.markspam then
        if formname == "mail:inbox" and mail.selected_idxs.inbox[name] then
            mail.mark_spam(name, mail.selected_idxs.inbox[name])
        end

        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.unmarkspam then
        if formname == "mail:inbox" and mail.selected_idxs.inbox[name] then
            mail.unmark_spam(name, mail.selected_idxs.inbox[name])
        end

        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)

    elseif fields.new then
        mail.show_compose(name)

    elseif fields.empty then
        mail.empty_trash(name)
        mail.show_mail_menu(name)

    elseif fields.contacts then
        mail.show_contacts(name)

    elseif fields.maillists then
        mail.show_maillists(name)

    elseif fields.options then
        mail.show_options(name)

    elseif fields.selectall then
        if formname == "mail:inbox" then
            local selected_number = #mail.selected_idxs.inbox[name]
            mail.selected_idxs.inbox[name] = {} -- reset for select, unselect and not existing
            mail.selected_idxs.multipleselection[name] = true -- enable as the button were pressed
            if selected_number < #getInbox() then -- then populate it if selection isn't full
                for _, msg in ipairs(getInbox()) do
                    table.insert(mail.selected_idxs.inbox[name], msg.id)
                end
            end
        elseif formname == "mail:outbox" then
            local selected_number = #mail.selected_idxs.outbox[name]
            mail.selected_idxs.outbox[name] = {} -- reset for select, unselect and not existing
            mail.selected_idxs.multipleselection[name] = true -- enable as the button were pressed
            if selected_number < #getOutbox() then -- then populate it if selection isn't full
                for _, msg in ipairs(getOutbox()) do
                    table.insert(mail.selected_idxs.outbox[name], msg.id)
                end
            end
        end

        mail.show_mail_menu(name)

    elseif fields.sortfield or fields.sortdirection or fields.filter then
        mail.show_mail_menu(name, sortfieldindex, sortdirection, filter)
    end

    return true
end)
