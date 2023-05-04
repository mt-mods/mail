-- helper function for tabbed options

function mail.show_options(playername)
    local index = mail.selected_idxs.optionstab[playername] or 1
    if not mail.selected_idxs.optionstab[playername] then
        mail.selected_idxs.optionstab[playername] = 1
    end
    if index == 1 then
        mail.show_settings(playername)
    elseif index == 2 then
        mail.show_about(playername)
    end
end
