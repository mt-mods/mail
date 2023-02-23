
mtt.register("send mail", function(callback)
    local auth_handler = minetest.get_auth_handler()
    if not auth_handler:get_auth("player1") then
        auth_handler:create_auth("player1", "test")
    end
    if not auth_handler:get_auth("player2") then
        auth_handler:create_auth("player2", "test")
    end

    -- send a mail
    mail.send("player1", "player2", "something", "blah")

    -- check the receivers inbox
    local list2 = mail.getMessages("player2")
    assert(list2 ~= nil and #list2 > 0)
    callback()
end)
