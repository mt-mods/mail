-- sub files
local MP = minetest.get_modpath(minetest.get_current_modname())

dofile(MP .. "/ui/inbox.lua")
dofile(MP .. "/ui/outbox.lua")
dofile(MP .. "/ui/drafts.lua")
dofile(MP .. "/ui/trash.lua")
dofile(MP .. "/ui/message.lua")
dofile(MP .. "/ui/receivers.lua")
dofile(MP .. "/ui/events.lua")
dofile(MP .. "/ui/contacts.lua")
dofile(MP .. "/ui/edit_contact.lua")
dofile(MP .. "/ui/select_contact.lua")
dofile(MP .. "/ui/maillists.lua")
dofile(MP .. "/ui/edit_maillists.lua")
dofile(MP .. "/ui/compose.lua")
dofile(MP .. "/ui/options.lua")
dofile(MP .. "/ui/settings.lua")
dofile(MP .. "/ui/about.lua")

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
    elseif index == 4 then
        mail.show_trash(playername)
    end
end
