extends Node2D

@export var projectile_scene: PackedScene
@export var range: float = 500.0

var projectile_container: Node2D
var slot_index: int = -1
var base_damage: int = 1
var is_shooting_anim: bool = false

@onready var fire_timer: Timer = $FireTimer
@onready var visual: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	fire_timer.timeout.connect(_fire)

	if visual != null:
		visual.animation_finished.connect(_on_animation_finished)
		visual.play("Idle")


func set_base_damage(val: int) -> void:
	base_damage = val


func _fire() -> void:
	if projectile_scene == null or projectile_container == null:
		return

	var target = _get_closest_enemy()
	if target == null:
		if visual != null and !is_shooting_anim:
			visual.play("Idle")
		return

	if visual != null:
		is_shooting_anim = true
		visual.play("Shoot")

	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = (target.global_position - global_position).normalized()
	projectile.damage = base_damage
	projectile_container.add_child(projectile)


func _get_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var best = null
	var best_dist := INF

	for enemy in enemies:
		if enemy == null or !is_instance_valid(enemy):
			continue

		var d = global_position.distance_to(enemy.global_position)
		if d < range and d < best_dist:
			best = enemy
			best_dist = d

	return best


func _on_animation_finished() -> void:
	if visual == null:
		return

	if visual.animation == "Shoot":
		is_shooting_anim = false
		visual.play("Idle")
