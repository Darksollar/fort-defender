extends Node2D

@export var pickup_type: String = "coin"
@export var value: int = 1
@export var target_position: Vector2 = Vector2(640, 650)
@export var delay: float = 0.25
@export var speed: float = 220.0

var delay_left: float = 0.0

func _ready() -> void:
	delay_left = delay

func _process(delta: float) -> void:
	if delay_left > 0.0:
		delay_left -= delta
		return

	var to_target = target_position - global_position

	if to_target.length() <= 10.0:
		queue_free()
		return

	global_position += to_target.normalized() * speed * delta
