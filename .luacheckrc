globals = {
	"mail",
}

read_globals = {
	-- Stdlib
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn", "indexof", "insert_all"}},
	beerchat = {fields = {"has_player_muted_player", "execute_callbacks"}},

	-- Minetest
	"minetest",
	"vector", "ItemStack",
	"dump",

	-- Deps
	"unified_inventory", "default", "sfinv_buttons",

	-- optional mods
	"mtt", "canonical_name"
}
