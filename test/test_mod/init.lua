
minetest.log("warning", "[TEST] integration-test enabled!")

minetest.register_on_mods_loaded(function()
	minetest.log("warning", "[TEST] starting tests")
	mail.send("spammer", "test", "subject", "body");
end)
