mtt.register("send mail", function(callback)
    -- create "player2"
    local auth_handler = minetest.get_auth_handler()
    auth_handler.set_password("player2", "")

    -- send a mail
    local success, err = mail.send({from = "player1", to = "player2", subject = "something", body = "blah"})
    assert(success)
    assert(not err)

    -- check the receivers inbox
    local entry = mail.get_storage_entry("player2")
    assert(entry ~= nil and #entry.inbox > 0)
    callback()
end)
