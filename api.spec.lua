mail.register_recipient_handler(function(_, name)
    if name:sub(1, 6) == "alias/" then
        return true, name:sub(7)
    elseif name == "list/test" then
        return true, {"alias/player1", "alias/player2"}
    elseif name == "list/reject" then
        return false, "It works (?)"
    end
end)

local received_count = {}
mail.register_on_player_receive(function(player)
	received_count[player] = (received_count[player] or 0) + 1
end)

local sent_count = 0
mail.register_on_receive(function()
	sent_count = sent_count+1
end)

local function assert_inbox_count(player_name, count)
    local entry = mail.get_storage_entry(player_name)
    assert(entry, player_name .. " has no mail entry")
    local actual_count = #entry.inbox
    assert(actual_count == count, ("incorrect mail count: %d expected, got %d"):format(count, actual_count))
    local player_received = received_count[player_name] or 0
    assert(player_received == count, ("incorrect receive count: %d expected, got %d"):format(count, player_received))
end

mtt.register("send mail", function(callback)
    -- send a mail to a list
    local success, err = mail.send({from = "player1", to = "list/test", subject = "something", body = "blah"})
    assert(success)
    assert(not err)
    assert_inbox_count("player2", 1)
    assert_inbox_count("player1", 0)
    assert(sent_count == 1)

    -- send a second mail to the list and also the sender
    success, err = mail.send({from = "player1", to = "list/test, alias/player1", subject = "something", body = "blah"})
    assert(success)
    assert(not err)
    assert_inbox_count("player2", 2)
    assert_inbox_count("player1", 1)
    assert(sent_count == 2)

    -- send a mail to list/reject - the mail should be rejected
    success, err = mail.send({from = "player1", to = "list/reject", subject = "something", body = "NO"})
    assert(not success)
    assert(type(err) == "string")
    assert_inbox_count("player2", 2)
    assert_inbox_count("player1", 1)
    assert(sent_count == 2)

    callback()
end)
