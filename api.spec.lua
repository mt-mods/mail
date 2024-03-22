mail.register_recipient_handler(function(_, name)
    if name:sub(1, 6) == "alias/" then
        return true, name:sub(7)
    elseif name == "list/test" then
        return true, {"alias/player1", "alias/player2"}
    elseif name == "list/reject" then
        return false, "It works (?)"
    end
end)
mail.update_maillist("player1", {
	owner = "player1",
	name = "recursive",
	desc = "",
	players = {"@recursive", "player1"},
}, "recursive")

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

local function assert_send(expected_success, ...)
	local success, err = mail.send(...)
	if expected_success then
		assert(success, ("expected mail to be sent, got error message: %s"):format(err))
		assert(not err, ("unexpected message after sending mail: %s"):format(err))
	else
		assert(not success, "expected mail to be rejected, mail was sent")
		assert(type(err) == "string", ("expected error message, got datum of type %s"):format(type(err)))
	end
end

mtt.register("send mail", function(callback)
    -- local maillists
    assert_send(true, {from = "player1", to = "@recursive", subject = "hello recursion", body = "blah"})
    assert_inbox_count("player1", 1)
    assert(sent_count == 1)

    -- do not allow empty recipients
    assert_send(false, {from = "player1", to = "@doesnotexist", subject = "should not be sent", body = "blah"})
    assert(sent_count == 1)

    -- send a mail to a list
    assert_send(true, {from = "player1", to = "list/test", subject = "something", body = "blah"})
    assert_inbox_count("player2", 1)
    assert_inbox_count("player1", 1)
    assert(sent_count == 2)

    -- send a second mail to the list and also the sender
    assert_send(true, {from = "player1", to = "list/test, alias/player1", subject = "something", body = "blah"})
    assert_inbox_count("player2", 2)
    assert_inbox_count("player1", 2)
    assert(sent_count == 3)

    -- send a mail to list/reject - the mail should be rejected
    assert_send(false, {from = "player1", to = "list/reject", subject = "something", body = "NO"})
    assert_inbox_count("player2", 2)
    assert_inbox_count("player1", 2)
    assert(sent_count == 3)

    callback()
end)
