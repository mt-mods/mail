-- helper function for tabbed mailing lists

function mail.show_maillists(playername)
    local index = mail.selected_idxs.mailliststab[playername] or 1
    if not mail.selected_idxs.mailliststab[playername] then
        mail.selected_idxs.mailliststab[playername] = 1
    end
    if index == 1 then
        mail.show_owned_maillists(playername)
    elseif index == 2 then
        mail.show_public_maillists(playername)
    end
end
