
local huddata = {}

core.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local data = {}

	data.imageid = player:hud_add({
		type = "image",
		name = "MailIcon",
		position = {x=0.52, y=0.52},
		text="",
		scale = {x=1,y=1},
		alignment = {x=0.5, y=0.5},
	})

	data.textid = player:hud_add({
		type = "text",
		name = "MailText",
		position = {x=0.55, y=0.52},
		text= "",
		scale = {x=1,y=1},
		alignment = {x=0.5, y=0.5},
	})


	huddata[name] = data
end)

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	huddata[name] = nil
end)


function mail.hud_update(playername, messages)
	local data = huddata[playername]
	local player = core.get_player_by_name(playername)

	if not data or not player then
		return
	end

	local unreadcount = 0
	for _, message in ipairs(messages) do
		if not message.read then
			unreadcount = unreadcount + 1
		end
	end

	if unreadcount == 0 or (not mail.get_setting(playername, "hud_notifications")) then
		player:hud_change(data.imageid, "text", "")
		player:hud_change(data.textid, "text", "")
	else
		player:hud_change(data.imageid, "text", "email_mail.png")
		player:hud_change(data.textid, "text", unreadcount .. " /mail")
	end

end
