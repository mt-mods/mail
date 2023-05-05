-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:settings"

function mail.show_settings(name)
	local formspec = [[
			size[10,6;]
			tabheader[0.3,1;optionstab;]] .. S("Settings") .. "," .. S("About") .. [[;1;false;false]
			button[9.35,0;0.75,0.5;back;X]

			box[0,0.8;3,0.45;#466432]
			label[0.2,0.8;]] .. S("Notifications") .. [[]
            checkbox[0,1.2;chat_notifications;]] .. S("Chat notifications") .. [[;]] ..
            tostring(mail.get_setting(name, "chat_notifications")) .. [[]
            checkbox[0,1.6;onjoin_notifications;]] .. S("On join notifications") .. [[;]] ..
            tostring(mail.get_setting(name, "onjoin_notifications")) .. [[]
            checkbox[0,2.0;hud_notifications;]] .. S("HUD notifications") .. [[;]] ..
            tostring(mail.get_setting(name, "hud_notifications")) .. [[]

			box[5,0.8;3,0.45;#466432]
			label[5.2,0.8;]] .. S("Message list") .. [[]
            checkbox[5,1.2;unreadcolorenable;]] .. S("Show unread in different color") .. [[;]] ..
            tostring(mail.get_setting(name, "unreadcolorenable")) .. [[]
            checkbox[5,1.6;cccolorenable;]] .. S("Show CC/BCC in different color") .. [[;]] ..
            tostring(mail.get_setting(name, "cccolorenable")) .. [[]

			label[5,2.6;]] .. S("Default sorting fields") .. [[]
            dropdown[5.5,3.0;2,0.5;defaultsortfield;]] ..
            S("From/To") .. "," .. S("Subject") .. "," .. S("Date") .. [[;]] ..
            tostring(mail.get_setting(name, "defaultsortfield")) .. [[;true]
            dropdown[7.5,3.0;2,0.5;defaultsortdirection;]] ..
            S("Ascending") .. "," .. S("Descending") .. [[;]] ..
            tostring(mail.get_setting(name, "defaultsortdirection")) .. [[;true]

            button[0,5.5;2.5,0.5;save;]] .. S("Save") .. [[]
            button[2.7,5.5;2.5,0.5;reset;]] .. S("Reset") .. [[]
            ]] .. mail.theme

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

    local playername = player:get_player_name()

	if fields.back then
		mail.show_mail_menu(playername)
		return

    elseif fields.optionstab == "1" then
        mail.selected_idxs.optionstab[playername] = 1

    elseif fields.optionstab == "2" then
        mail.selected_idxs.optionstab[playername] = 2
        mail.show_about(playername)
        return

    elseif fields.chat_notifications then
        mail.selected_idxs.chat_notifications[playername] = fields.chat_notifications == "true"

    elseif fields.onjoin_notifications then
        mail.selected_idxs.onjoin_notifications[playername] = fields.onjoin_notifications == "true"

    elseif fields.hud_notifications then
        mail.selected_idxs.hud_notifications[playername] = fields.hud_notifications == "true"

    elseif fields.unreadcolorenable then
        mail.selected_idxs.unreadcolorenable[playername] = fields.unreadcolorenable == "true"

    elseif fields.cccolorenable then
        mail.selected_idxs.cccolorenable[playername] = fields.cccolorenable == "true"

    elseif fields.save then
        -- checkboxes
        mail.set_setting(playername, "chat_notifications", mail.selected_idxs.chat_notifications[playername])
        mail.set_setting(playername, "onjoin_notifications", mail.selected_idxs.onjoin_notifications[playername])
        mail.set_setting(playername, "hud_notifications", mail.selected_idxs.hud_notifications[playername])
        mail.set_setting(playername, "unreadcolorenable", mail.selected_idxs.unreadcolorenable[playername])
        mail.set_setting(playername, "cccolorenable", mail.selected_idxs.cccolorenable[playername])
        -- dropdowns
        local defaultsortfield = fields.defaultsortfield or mail.get_setting("defaultsortfield")
        local defaultsortdirection = fields.defaultsortdirection or mail.get_setting("defaultsortdirection")
        mail.set_setting(playername, "defaultsortfield", tonumber(defaultsortfield))
        mail.set_setting(playername, "defaultsortdirection", tonumber(defaultsortdirection))
        -- update visuals
        mail.hud_update(playername, mail.get_storage_entry(playername).inbox)
        mail.show_settings(playername)

    elseif fields.reset then
        mail.reset_settings(playername)
        mail.show_settings(playername)
	end
	return
end)
