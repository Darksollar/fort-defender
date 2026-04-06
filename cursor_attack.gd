extends Node

@export var radius: float = 55.0
@export var damage: int = 1
@export var cooldown: float = 0.18
@export var wall_y: float = 900.0

var cooldown_left: float = 0.0

func _process(delta: float) -> void:
	if cooldown_left > 0.0:
		cooldown_left -= delta

	if Input.is_action_just_pressed("click_attack") and cooldown_left <= 0.0:
		attack_at_mouse()
		cooldown_left = cooldown

func attack_at_mouse() -> void:
	var mouse_pos = get_viewport().get_mouse_position()

	# Don't let player click inside the fort strip or the right sidebar
	if mouse_pos.y >= wall_y or mouse_pos.x >= 1560.0:
		return

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(mouse_pos) <= radius:
			enemy.take_damage(damage)
