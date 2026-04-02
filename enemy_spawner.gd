extends Node

@export var enemy_scene: PackedScene
@export var coin_scene: PackedScene
@export var crystal_scene: PackedScene
@export var enemies_container: Node2D
@export var pickups_container: Node2D
@export var fort_zone: Node
@export var spawn_y: float = -40.0
@export var min_x: float = 60.0
@export var max_x: float = 1220.0
@export var pickup_target_position: Vector2 = Vector2(640, 650)

@onready var timer: Timer = $Timer

func _ready() -> void:
	randomize()
	timer.timeout.connect(_spawn_enemy)

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(min_x, max_x), spawn_y)
	enemy.fort_zone = fort_zone
	enemy.died.connect(_on_enemy_died)
	enemies_container.add_child(enemy)

func _on_enemy_died(drop_position: Vector2) -> void:
	if coin_scene != null:
		var coin = coin_scene.instantiate()
		coin.global_position = drop_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		coin.target_position = pickup_target_position
		pickups_container.add_child(coin)

	if crystal_scene != null:
		var crystal = crystal_scene.instantiate()
		crystal.global_position = drop_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		crystal.target_position = pickup_target_position
		pickups_container.add_child(crystal)
