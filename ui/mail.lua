-- helper function for tabbed overview

function mail.show_mail_menu(playername, sortfield, sortdirection, filter)
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
    end
end
