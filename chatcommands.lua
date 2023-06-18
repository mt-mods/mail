minetest.register_chatcommand("mail",{
	description = "Open the mail interface",
	func = function(name, param)
		if #param > 0 then -- if param is not empty
			mail.show_compose(name, param) -- make a new message
		else
			mail.show_mail_menu(name) -- show main menu
		end
	end
})
