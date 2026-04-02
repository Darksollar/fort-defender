extends Node2D

@export var projectile_scene: PackedScene
@export var projectile_container_path: NodePath
@export var range: float = 500.0

@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	fire_timer.timeout.connect(_fire)

func _fire() -> void:
	var target = _get_closest_enemy()
	if target == null:
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = (target.global_position - global_position).normalized()

	get_node(projectile_container_path).add_child(projectile)

func _get_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var best = null
	var best_dist = INF

	for enemy in enemies:
		var d = global_position.distance_to(enemy.global_position)
		if d < range and d < best_dist:
			best = enemy
			best_dist = d

	return best
