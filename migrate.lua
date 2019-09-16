
-- migrate from mail.db to player-file-based mailbox

mail.migrate = function()

	local file = io.open(minetest.get_worldpath().."/mail.db", "r")
	if file then
		print("[mail] migrating to new per-player storage")
		minetest.mkdir(mail.maildir)

		local data = file:read("*a")
		local oldmails = minetest.deserialize(data)
		file:close()

		for name, oldmessages in pairs(oldmails) do
			mail.setMessages(name, oldmessages)
		end

		-- rename file
		print("[mail] migration done, renaming old mail.db")
		os.rename(minetest.get_worldpath().."/mail.db", minetest.get_worldpath().."/mail.db.old")
	end

end
