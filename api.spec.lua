mtt.register("send mail", function(callback)
    -- send a mail
    local success, err = mail.send({from = "player1", to = "player2", subject = "something", body = "blah"})
    assert(success)
    assert(not err)

    -- check the receivers inbox
    local entry = mail.get_storage_entry("player2")
    assert(entry)
    assert(#entry.inbox > 0)
    callback()
end)
