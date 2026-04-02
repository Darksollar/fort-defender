extends Node

signal health_changed(current: int, max_health: int)
signal destroyed

@export var max_health: int = 100
@export var wall_y: float = 580.0

var health: int

func _ready() -> void:
	health = max_health
	health_changed.emit(health, max_health)

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)

	if health <= 0:
		destroyed.emit()
