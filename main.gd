extends Node2D

@onready var fort_zone = $WorldNode2D/FortZone
@onready var fort_health_label = $HUD/SidebarRoot/SidebarMargin/SidebarVBox/FortHealthLabel
@onready var money_label = $HUD/SidebarRoot/SidebarMargin/SidebarVBox/MoneyLabel
@onready var player_level_label = $HUD/SidebarRoot/SidebarMargin/SidebarVBox/PlayerLevelLabel
@onready var player_xp_label = $HUD/SidebarRoot/SidebarMargin/SidebarVBox/PlayerXPLabel
@onready var enemy_spawner = $WorldNode2D/EnemySpawner
@onready var archer_manager = $WorldNode2D/ArcherManager
@onready var buy_archer_button = $HUD/SidebarRoot/SidebarMargin/SidebarVBox/BuyArcherButton
@onready var level_up_overlay = $HUD/LevelUpOverlay

const ARCHER_COST: int = 10

# Money
var money: int = 0:
	set(value):
		money = value
		_update_money_label()
		_update_buy_button_state()

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

# Level-up / run-state modifiers
var pending_level_ups: int = 0
var archer_damage_bonus: int = 0
var current_level_up_choices: Array[Dictionary] = []


func _ready() -> void:
	fort_zone.health_changed.connect(_on_fort_health_changed)
	fort_zone.destroyed.connect(_on_fort_destroyed)
	_on_fort_health_changed(fort_zone.health, fort_zone.max_health)

	_update_money_label()
	_update_level_label()
	_update_xp_label()

	if buy_archer_button:
		buy_archer_button.pressed.connect(_on_buy_archer_button_pressed)
		_update_buy_button_state()

	if level_up_overlay:
		level_up_overlay.upgrade_chosen.connect(_on_upgrade_chosen)

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
		pending_level_ups += 1
	current_xp = total
	_try_open_level_up()


func _try_open_level_up() -> void:
	if pending_level_ups > 0 and level_up_overlay and not level_up_overlay.visible:
		current_level_up_choices = UpgradePool.get_choices(3)
		level_up_overlay.show_choices(current_level_up_choices)
		get_tree().paused = true


func _on_upgrade_chosen(data: Dictionary) -> void:
	_apply_upgrade(data)
	pending_level_ups -= 1
	_on_upgrade_resolved()


func _on_upgrade_resolved() -> void:
	if pending_level_ups > 0:
		_try_open_level_up()
	else:
		_close_overlay_responsibly()


func _apply_upgrade(data: Dictionary) -> void:
	var key: String = data.get("effect_key", "")
	var val: int = data.get("effect_value", 0)
	match key:
		"cursor_damage":
			var ca = get_node_or_null("WorldNode2D/CursorAttack")
			if ca:
				ca.damage += val
		"archer_damage":
			archer_damage_bonus += val
			var fort_units = get_node_or_null("WorldNode2D/FortUnits")
			if fort_units:
				for child in fort_units.get_children():
					if child.has_method("set_base_damage"):
						child.set_base_damage(child.get("base_damage") + val)
		"fort_max_hp":
			fort_zone.max_health += val
			fort_zone.health += val
			fort_zone.health_changed.emit(fort_zone.health, fort_zone.max_health)


func _close_overlay_responsibly() -> void:
	if level_up_overlay and level_up_overlay.visible:
		level_up_overlay.hide_overlay()
	get_tree().paused = false


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


func buy_archer() -> bool:
	if money < ARCHER_COST:
		return false
	if archer_manager == null or not archer_manager.has_free_slot():
		return false

	money -= ARCHER_COST
	var success = archer_manager.add_archer(1 + archer_damage_bonus)
	if success:
		_update_money_label()
		_update_buy_button_state()
	return success


func _on_buy_archer_button_pressed() -> void:
	buy_archer()


func _update_buy_button_state() -> void:
	if not buy_archer_button:
		return
	var can_buy = money >= ARCHER_COST and archer_manager != null and archer_manager.has_free_slot()
	buy_archer_button.disabled = not can_buy
	buy_archer_button.flat = not can_buy
