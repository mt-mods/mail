local S = minetest.get_translator("mail")
local has_canonical_name = minetest.get_modpath("canonical_name")

local function deliver_mail_to_player(name, msg)
	-- add to inbox
	local entry = mail.get_storage_entry(name)
	table.insert(entry.inbox, msg)
	mail.set_storage_entry(name, entry)

	-- notify recipients that happen to be online
	local mail_alert = S("You have a new message from @1! Subject: @2",  msg.from, msg.subject) ..
	"\n" .. S("To view it, type /mail")
	local inventory_alert = S("You could also use the button in your inventory.")
	local player = minetest.get_player_by_name(name)
	if player then
		if mail.get_setting(name, "chat_notifications") == true then
			minetest.chat_send_player(name, mail_alert)
			if minetest.get_modpath("unified_inventory") or minetest.get_modpath("sfinv_buttons") then
				minetest.chat_send_player(name, inventory_alert)
			end
		end
		if mail.get_setting(name, "sound_notifications") == true then
			minetest.sound_play("mail_notif", {to_player=name})
		end
		local receiver_entry = mail.get_storage_entry(name)
		local receiver_messages = receiver_entry.inbox
		mail.hud_update(name, receiver_messages)
	end
end

mail.register_recipient_handler(function(_, pname)
	if not minetest.player_exists(pname) then
		return nil
	end
	return true, function(mail)
		deliver_mail_to_player(pname, mail)
	end
end)

if has_canonical_name then
	mail.register_recipient_handler(function(_, name)
		local realname = canonical_name.get(name)
		if realname then
			return true, realname
		end
	end)
end
