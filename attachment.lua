
local invmap = {}


mail.getAttachmentInventory = function(playername)
	return invmap[playername]
end

mail.getAttachmentInventoryName = function(playername)
	return "mail:" .. playername
end


minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local inv = minetest.create_detached_inventory(mail.getAttachmentInventoryName(name), {})

	invmap[name] = inv
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	invmap[name] = nil
	if minetest.remove_detached_inventory then
		minetest.remove_detached_inventory(mail.getAttachmentInventoryName(name))
	end
end)
