extends Node

@export var enemy_scene: PackedScene
@export var enemies_container: Node2D
@export var spawn_y: float = -40.0
@export var min_x: float = 60.0
@export var max_x: float = 1220.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	randomize()
	timer.timeout.connect(_spawn_enemy)

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(randf_range(min_x, max_x), spawn_y)
	enemies_container.add_child(enemy)
