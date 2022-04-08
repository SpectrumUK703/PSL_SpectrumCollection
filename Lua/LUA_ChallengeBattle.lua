local num = #BTL_challengebtllist

BTL_challengebtllist[num+1] = 	{
	name = "Player Enemy Team",
	description = "A random group of player enemies.",
	difficulty = 7,
	time = TICRATE*60*15,
	music = "PVP",
	items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}, {"homunculus", 4}, {"dekaja gem", 5}, {"dekunda gem", 5},  {"patra gem", 5}, {"super1up", 3}},
	subpersonas = {},
	level = 99,
	waves = {
		{"player_enemy", "player_enemy", "player_enemy", "player_enemy"},
	},
}

BTL_challengebtllist[num+2] = 	{
	name = "Player Boss Team",
	description = "A random group of player enemies, but stronger.",
	difficulty = 8,
	time = TICRATE*60*20,
	music = "VSNQST",
	items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}, {"homunculus", 4}, {"dekaja gem", 5}, {"dekunda gem", 5},  {"patra gem", 5}, {"super1up", 3}},
	subpersonas = {},
	level = 99,
	waves = {
		{"player_enemy_boss", "player_enemy_boss", "player_enemy_boss", "player_enemy_boss"},
	},
}
