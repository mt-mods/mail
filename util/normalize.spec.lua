
mtt.register("util/normalize_players_and_add_recipients", function(callback)
    local recipients = {}
    local undeliverable = {}
    local to = mail.normalize_players_and_add_recipients("player1,player2", recipients, undeliverable)

    assert(to == "player1, player2")
    assert(not next(undeliverable))
    assert(recipients["player1"])
    assert(recipients["player2"])
    callback()
end)