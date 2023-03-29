
mtt.register("setup", function(callback)
    -- create test players
    local auth_handler = minetest.get_auth_handler()
    auth_handler.set_password("player1", "")
    auth_handler.set_password("player2", "")
    auth_handler.set_password("player3", "")

    callback()
end)