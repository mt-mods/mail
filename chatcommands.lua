minetest.register_chatcommand("mail",{
	description = "Open the mail interface",
	func = function(name)
		mail.show_mail_menu(name)
	end
})
