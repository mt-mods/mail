local has_xban2_mod = minetest.get_modpath("xban2")

-- auth request from webmail
function mail.handlers.auth(auth)
	local handler = minetest.get_auth_handler()
	minetest.log("action", "[webmail] auth: " .. auth.name)

	local success = false
	local banned = false
	local message = ""

	if mail.webmail.disallow_banned_players and has_xban2_mod then
		-- check xban db
		local xbanentry = xban.find_entry(auth.name)
		if xbanentry and xbanentry.banned then
			banned = true
			message = "Banned!"
		end
	end

	if not banned then
		-- check tan
		local tan = mail.tan[auth.name]
		if tan ~= nil then
			success = tan == auth.password
		end

		-- check auth
		if not success then
			local entry = handler.get_auth(auth.name)
			if entry and minetest.check_password_entry(auth.name, entry.password, auth.password) then
				success = true
			end
		end
	end

	mail.channel.send({
		type = "auth",
		data = {
			name = auth.name,
			success = success,
			message = message
		}
	})
end
