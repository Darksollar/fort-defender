extends Area2D

@export var speed: float = 80.0
@export var hp: int = 3
@export var fort_y: float = 580.0

func _ready() -> void:
	add_to_group("enemies")

func _process(delta: float) -> void:
	position.y += speed * delta

	if position.y >= fort_y:
		reach_fort()

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	queue_free()

func reach_fort() -> void:
	queue_free()
