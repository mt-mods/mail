
-- migrate from mail.db to player-file-based mailbox

mail.migrate = function()
	-- create directory, just in case
	minetest.mkdir(mail.maildir)
	minetest.mkdir(mail.contactsdir)

	local file = io.open(minetest.get_worldpath().."/mail.db", "r")
	if file then
		print("[mail] migrating to new per-player storage")

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


mail.migrate_contacts = function(playername)
	local file = io.open(mail.getContactsFile(playername), 'r')
	if not file then
		-- file doesn't exist! This is a case for Migrate Man!
		local messages = mail.getMessages(playername)
		local contacts = {}

		if messages and not contacts then
			for _, message in pairs(messages) do
				mail.ensure_new_format(message)
				if contacts[string.lower(message.from)] == nil then
					contacts[string.lower(message.from)] = {
						name = message.from,
						note = "",
					}
				end
			end
		end
	else
		file:close()	-- uh, um, nope, let's leave those alone, shall we?
	end
end
