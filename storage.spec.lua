
mtt.register("storage", function(callback)
    -- sanity checks
    local playername = "player1"
    local entry = mail.get_storage_entry(playername)
    assert(entry)

    -- create
    local contact = {
        name = "other-player",
        note = "my-note"
    }
    mail.update_contact(playername, contact)

    -- read
    local contacts = mail.get_contacts(playername)
    assert(#contacts == 1)
    assert(contacts[1].note == contact.note)
    assert(contacts[1].name == contact.name)

    -- read through api
    local contacts2 = mail.get_contacts(playername)
    assert(#contacts2 == 1)
    assert(contacts2[1].note == contact.note)
    assert(contacts2[1].name == contact.name)

    -- update
    mail.update_contact(playername, {
        name = contact.name,
        note = "xy"
    })

    -- read updated
    contacts = mail.get_contacts(playername)
    assert(#contacts == 1)
    assert(contacts[1].note == "xy")
    assert(contacts[1].name == contact.name)

    -- delete
    mail.delete_contact(playername, contact.name)
    contacts = mail.get_contacts(playername)
    assert(#contacts == 0)

    callback()
end)