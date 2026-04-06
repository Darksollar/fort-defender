extends Node

signal pickup_collected(pickup_type: String, value: int)

@export var enemy_scene: PackedScene
@export var enemy_slow_scene: PackedScene
@export var slow_spawn_chance: float = 0.25

@export var coin_scene: PackedScene
@export var crystal_scene: PackedScene
@export var enemies_container: Node2D
@export var pickups_container: Node2D
@export var fort_zone: Node
@export var spawn_y: float = -40.0
@export var min_x: float = 40.0
@export var max_x: float = 1520.0
@export var pickup_target_position: Vector2 = Vector2(780, 990)

@onready var timer: Timer = $Timer

func _ready() -> void:
	randomize()
	timer.timeout.connect(_spawn_enemy)

func _spawn_enemy() -> void:
	var scene_to_spawn: PackedScene = enemy_scene

	if enemy_slow_scene != null and randf() < slow_spawn_chance:
		scene_to_spawn = enemy_slow_scene

	var enemy = scene_to_spawn.instantiate()
	enemy.position = Vector2(randf_range(min_x, max_x), spawn_y)
	enemy.fort_zone = fort_zone
	enemy.died.connect(_on_enemy_died)
	enemies_container.add_child(enemy)

func _on_enemy_died(drop_position: Vector2) -> void:
	if coin_scene != null:
		var coin = coin_scene.instantiate()
		coin.global_position = drop_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		coin.target_position = pickup_target_position
		coin.value = 1
		coin.pickup_type = "coin"
		coin.collected.connect(_on_pickup_collected)
		pickups_container.add_child(coin)

	if crystal_scene != null:
		var crystal = crystal_scene.instantiate()
		crystal.global_position = drop_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		crystal.target_position = pickup_target_position
		crystal.value = 2
		crystal.pickup_type = "crystal"
		crystal.collected.connect(_on_pickup_collected)
		pickups_container.add_child(crystal)

func _on_pickup_collected(_pickup_type: String, value: int) -> void:
	print("ENEMY_SPAWNER: Forwarding pickup_collected type=", _pickup_type, ", value=", value)
	pickup_collected.emit(_pickup_type, value)
