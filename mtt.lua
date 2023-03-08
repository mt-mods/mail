mtt.register("send mail", function(callback)
    -- create "player2"
    local auth_handler = minetest.get_auth_handler()
    auth_handler.set_password("player2", "")

    -- send a mail
    mail.send("player1", "player2", "something", "blah")

    -- check the receivers inbox
    local list2 = mail.getPlayerInboxMessages("player2")
    assert(list2 ~= nil and #list2 > 0)
    callback()
end)
