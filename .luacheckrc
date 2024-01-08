globals = {
	"mail",
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"minetest",
	"vector", "ItemStack",
	"dump",

	-- Deps
	"unified_inventory", "default", "sfinv_buttons",

	-- optional mods
	"mtt", "canonical_name"
}
