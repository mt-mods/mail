
mtt.register("send mail", function(callback)
    -- send a mail
    mail.send("player1", "player2", "something", "blah")

    -- check the receivers inbox
    local list2 = mail.getMessages("player2")
    assert(list2 ~= nil and #list2 > 0)
    callback()
end)