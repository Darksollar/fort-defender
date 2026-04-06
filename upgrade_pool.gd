class_name UpgradePool
extends Object

static func get_all() -> Array[Dictionary]:
	return [
		{
			"id": "cursor_damage_up",
			"name": "Cursor Power",
			"description": "+1 cursor damage",
			"max_stacks": 999,
			"effect_key": "cursor_damage",
			"effect_value": 1
		},
		{
			"id": "archer_damage_up",
			"name": "Sharpened Arrows",
			"description": "+1 archer damage",
			"max_stacks": 999,
			"effect_key": "archer_damage",
			"effect_value": 1
		},
		{
			"id": "fort_max_hp_up",
			"name": "Fortified Walls",
			"description": "+10 max fort HP and heal 10",
			"max_stacks": 999,
			"effect_key": "fort_max_hp",
			"effect_value": 10
		}
	]


static func get_choices(n: int = 3) -> Array[Dictionary]:
	var pool := get_all()
	pool.shuffle()
	var result: Array[Dictionary] = []
	for i in min(n, pool.size()):
		result.append(pool[i])
	return result
