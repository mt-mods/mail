-- helper function for tabbed overview

function mail.show_mail_menu(playername, sortfield, sortdirection)
    local index = mail.selected_idxs.boxtab[playername] or 1
    if index == 1 then
        mail.show_inbox(playername, sortfield, sortdirection)
    elseif index == 2 then
        mail.show_sent(playername, sortfield, sortdirection)
    elseif index == 3 then
        mail.show_drafts(playername)
    end
end
