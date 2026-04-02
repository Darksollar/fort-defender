extends Node2D

@onready var fort_zone = $WorldNode2D/FortZone
@onready var fort_health_label = $HUD/FortHealthLabel
@onready var money_label = $HUD/MoneyLabel
@onready var player_level_label = $HUD/PlayerLevelLabel
@onready var player_xp_label = $HUD/PlayerXPLabel
@onready var enemy_spawner = $WorldNode2D/EnemySpawner

# Money
var money: int = 0:
	set(value):
		money = value
		_update_money_label()

# XP / Level
var player_level: int = 1:
	set(value):
		player_level = value
		_update_level_label()

var current_xp: int = 0:
	set(value):
		current_xp = value
		_update_xp_label()

var xp_to_next_level: int = 300


func _ready() -> void:
	fort_zone.health_changed.connect(_on_fort_health_changed)
	fort_zone.destroyed.connect(_on_fort_destroyed)
	_on_fort_health_changed(fort_zone.health, fort_zone.max_health)

	_update_money_label()
	_update_level_label()
	_update_xp_label()

	call_deferred("_connect_spawner_signals")


func _connect_spawner_signals() -> void:
	if enemy_spawner and enemy_spawner.has_signal("pickup_collected"):
		enemy_spawner.pickup_collected.connect(_on_pickup_collected)


func _on_pickup_collected(pickup_type: String, value: int) -> void:
	if pickup_type == "coin":
		money += value
	elif pickup_type == "crystal":
		add_xp(value)


func add_xp(amount: int) -> void:
	var total = current_xp + amount
	while total >= xp_to_next_level:
		total -= xp_to_next_level
		player_level += 1
		xp_to_next_level = _calc_required_xp_for_level(player_level)
	current_xp = total


func _calc_required_xp_for_level(level: int) -> int:
	# L1=300, L2=400, L3=500, L4=600, ...
	return 300 + (level - 1) * 100


func _update_money_label() -> void:
	if money_label:
		money_label.text = "$%d" % money


func _update_level_label() -> void:
	if player_level_label:
		player_level_label.text = "Lv.%d" % player_level


func _update_xp_label() -> void:
	if player_xp_label:
		player_xp_label.text = "%d / %d" % [current_xp, xp_to_next_level]


func _on_fort_health_changed(current: int, max_health: int) -> void:
	fort_health_label.text = "Fort HP: %d / %d" % [current, max_health]


func _on_fort_destroyed() -> void:
	fort_health_label.text = "FORT DESTROYED"
	get_tree().paused = true
