-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:message"

local function interleaveMsg(body)
	return "> " .. (body or ""):gsub("\n", "\n> ")
end


function mail.show_message(name, id)
	local message = mail.get_message(name, id)
	if not message then
		-- message not found or vanished
		return
	end

	mail.selected_idxs.message[name] = id

	local formspec = [[
			size[10,10]

			box[0,0;7,1.9;]] .. mail.get_color("highlighted") .. [[]

			button[9.25,0.15;0.75,0.5;back;X]
			button[7.25,-0.07;2,1;receivers;]] .. S("Receivers") .. [[]

			label[0.2,0.1;]] .. S("From") .. [[: %s]
			label[0.2,0.5;]] .. S("To") .. [[: %s]
			label[0.2,0.9;]] .. S("CC") .. [[: %s]
			label[0.2,1.3;]] .. S("Date") .. [[: %s]
			tooltip[0.2,1.3;4.8,0.4;]] .. mail.time_ago(message.time) .. [[]

			label[0,2.1;]] .. S("Subject") .. [[: %s]
			textarea[0.25,2.6;8,7.0;;;%s]

			button[7.25,1.0;2.75,1;reply;]] .. S("Reply") .. [[]
			button[7.25,1.8;2.75,1;replyall;]] .. S("Reply all") .. [[]
			button[7.25,2.6;2.75,1;forward;]] .. S("Forward") .. [[]
			button[7.25,3.6;2.75,1;markspam;]] .. S("Mark Spam") .. [[]
			button[7.25,4.4;2.75,1;unmarkspam;]] .. S("Unmark Spam") .. [[]

			box[7.25,5.4;2.5,4.0;]] .. mail.get_color("disabled") .. [[]

			button[7.25,9.5;2.75,1;delete;]] .. S("Delete") .. [[]

			tooltip[reply;]] .. S("Reply only to the sender") .. [[]
			tooltip[replyall;]] .. S("Reply to all involved people") .. [[]
			tooltip[forward;]] .. S("Transfer message to other people") .. [[]
		]] .. mail.theme

	local from = minetest.formspec_escape(message.from) or ""
	local to = minetest.formspec_escape(message.to) or ""
	if string.len(to) > 70 then to = string.sub(to, 1, 67) .. "..." end
	local cc = minetest.formspec_escape(message.cc) or ""
	if string.len(cc) > 50 then cc = string.sub(cc, 1, 47) .. "..." end
	local date = type(message.time) == "number"
		and minetest.formspec_escape(os.date(mail.get_setting(name, "date_format"), message.time)) or ""
	local subject = minetest.formspec_escape(message.subject) or ""
	local body = minetest.formspec_escape(message.body) or ""
	formspec = string.format(formspec, from, to, cc, date, subject, body)

	if not message.read and mail.get_setting(name, "auto_marking_read") then
		-- mark as read
		mail.mark_read(name, id)
	end

	minetest.show_formspec(name, FORMNAME, formspec)
end

function mail.reply(name, message)
	if not message then
		-- TODO: workaround for https://github.com/mt-mods/mail/issues/84
		minetest.log("error", "[mail] reply called with nil message for player: " .. name)
		minetest.log("error", "[mail] current mail-context: " .. dump(mail.selected_idxs))
		return
	end
	mail.show_compose(name, message.from, "Re: "..message.subject, interleaveMsg(message.body))
end

function mail.replyall(name, message)
	if not message then
		-- TODO: workaround for https://github.com/mt-mods/mail/issues/84
		minetest.log("error", "[mail] replyall called with nil message for player: " .. name)
		minetest.log("error", "[mail] current mail-context: " .. dump(mail.selected_idxs))
		return
	end

	-- new recipients are the sender plus the original recipients, minus ourselves
	local recipients = message.to or ""
	if message.from ~= nil then
		recipients = message.from .. ", " .. recipients
	end
	recipients = mail.parse_player_list(recipients)
	for k,v in pairs(recipients) do
		if v == name then
			table.remove(recipients, k)
			break
		end
	end
	recipients = mail.concat_player_list(recipients)

	-- new CC is old CC minus ourselves
	local cc = mail.parse_player_list(message.cc)
	for k,v in pairs(cc) do
		if v == name then
			table.remove(cc, k)
			break
		end
	end
	cc = mail.concat_player_list(cc)

	mail.show_compose(name, recipients, "Re: "..message.subject, interleaveMsg(message.body), cc)
end

function mail.forward(name, message)
	mail.show_compose(name, "", "Fw: " .. (message.subject or ""), interleaveMsg(message.body))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()

	local message = mail.get_message(name, mail.selected_idxs.message[name])

	if fields.back then
		mail.show_mail_menu(name)
		return true	-- don't uselessly set messages

	elseif fields.reply then
		mail.reply(name, message)

	elseif fields.replyall then
		mail.replyall(name, message)

	elseif fields.forward then
		mail.forward(name, message)

	elseif fields.markspam then
		mail.mark_spam(name, message.id)

	elseif fields.unmarkspam then
		mail.unmark_spam(name, message.id)

	elseif fields.delete then
        if mail.get_setting(name, "trash_move_enable") and mail.selected_idxs.boxtab[name] ~= 4 then
			mail.trash_mail(name, message.id)
		else
			mail.delete_mail(name, message.id, true)
		end
		mail.show_mail_menu(name)

	elseif fields.receivers then
		mail.show_receivers(name, message.id)
	end

	return true
end)
