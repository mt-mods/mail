

minetest.register_chatcommand("webmail_tan", {
	description = "generates a tan (temporary access number) for the webmail access",
	func = function(name)
    local tan = "" .. math.random(1000, 9999)
    mail.tan[name] = tan

		return true, "Your tan is " .. tan .. ", it will expire upon leaving the game"
	end
})

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mail.tan[name] = nil
end)
