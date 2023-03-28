

mtt.register("uuid", function(callback)
    assert(mail.new_uuid())
    assert(mail.new_uuid() ~= mail.new_uuid())
    callback()
end)