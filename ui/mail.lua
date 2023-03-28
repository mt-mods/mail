-- helper function for tabbed overview

function mail.show_mail_menu(playername)
    local index = mail.selected_idxs.boxtab[playername] or 1
    if index == 1 then
        mail.show_inbox(playername)
    elseif index == 2 then
        mail.show_sent(playername)
    end
end