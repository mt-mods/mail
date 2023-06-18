-- helper function for tabbed overview

function mail.show_mail_menu(playername, sortfield, sortdirection, filter)
    -- create contexts
    local entry = mail.get_storage_entry(playername)
    mail.messages_context.inbox[playername] = mail.messages_context.inbox[playername] or entry.inbox
    mail.messages_context.outbox[playername] = mail.messages_context.outbox[playername] or entry.outbox
    mail.messages_context.drafts[playername] = mail.messages_context.drafts[playername] or entry.drafts
    mail.messages_context.trash[playername] = mail.messages_context.trash[playername] or entry.trash

    local index = mail.selected_idxs.boxtab[playername] or 1
    if not mail.selected_idxs.boxtab[playername] then
        mail.selected_idxs.boxtab[playername] = 1
    end
    if index == 1 then
        mail.show_inbox(playername, sortfield, sortdirection, filter)
    elseif index == 2 then
        mail.show_outbox(playername, sortfield, sortdirection, filter)
    elseif index == 3 then
        mail.show_drafts(playername)
    elseif index == 4 then
        mail.show_trash(playername)
    end
end
