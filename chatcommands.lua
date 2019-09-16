minetest.register_chatcommand("mail",{
	description = "Open the mail interface",
	func = function(name)
		mail.show_inbox(name)
	end
})
