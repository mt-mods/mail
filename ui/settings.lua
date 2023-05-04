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
            checkbox[0,1.2;chatnotif;]] .. S("Chat notifications") .. [[;]] ..
            tostring(mail.get_setting(name, "chatnotif")) .. [[]
            checkbox[0,1.6;onjoinnotif;]] .. S("On join notifications") .. [[;]] ..
            tostring(mail.get_setting(name, "onjoinnotif")) .. [[]
            checkbox[0,2.0;hudnotif;]] .. S("HUD notifications") .. [[;]] ..
            tostring(mail.get_setting(name, "hudnotif")) .. [[]

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

            button[0,5.5;2.5,0.5;reset;]] .. S("Reset") .. [[]
            ]] .. mail.theme

	minetest.show_formspec(name, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

    local playername = player:get_player_name()

	if fields.back then
        local defaultsortfield = fields.defaultsortfield or mail.get_setting("defaultsortfield")
        local defaultsortdirection = fields.defaultsortdirection or mail.get_setting("defaultsortdirection")
        mail.set_setting(playername, {
                name = "defaultsortfield",
                value = tonumber(defaultsortfield),
        })

        mail.set_setting(playername, {
                name = "defaultsortdirection",
                value = tonumber(defaultsortdirection),
        })
		mail.show_mail_menu(playername)
		return

    elseif fields.reset then
        mail.reset_settings(playername)

    elseif fields.optionstab == "1" then
        mail.selected_idxs.optionstab[playername] = 1

    elseif fields.optionstab == "2" then
        mail.selected_idxs.optionstab[playername] = 2
        mail.show_about(playername)
        return

    elseif fields.chatnotif then
        local setting = {
            name = "chatnotif",
            value = fields.chatnotif == "true",
        }
        mail.set_setting(playername, setting)

    elseif fields.onjoinnotif then
        local setting = {
            name = "onjoinnotif",
            value = fields.onjoinnotif == "true",
        }
        mail.set_setting(playername, setting)

    elseif fields.hudnotif then
        local setting = {
            name = "hudnotif",
            value = fields.hudnotif == "true",
        }
        mail.set_setting(playername, setting)
        mail.hud_update(playername, mail.get_storage_entry(playername).inbox)

    elseif fields.unreadcolorenable then
        local setting = {
            name = "unreadcolorenable",
            value = fields.unreadcolorenable == "true",
        }
        mail.set_setting(playername, setting)

    elseif fields.cccolorenable then
        local setting = {
            name = "cccolorenable",
            value = fields.cccolorenable == "true",
        }
        mail.set_setting(playername, setting)
	end

	mail.show_settings(playername)
	return
end)
