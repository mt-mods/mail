
if minetest.get_modpath("unified_inventory") then

	unified_inventory.register_button("mail", {
			type = "image",
			image = "mail_button.png",
			tooltip = "Mail",
			action = function(player)
				mail.show_mail_menu(player:get_player_name())
			end
		})
end

if minetest.get_modpath("sfinv_buttons") then
	sfinv_buttons.register_button("mail", {
			title = "Mail",
			image = "mail_button.png",
			action = function(player)
				mail.show_mail_menu(player:get_player_name())
			end
		})
end
