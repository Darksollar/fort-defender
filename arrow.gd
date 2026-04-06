extends Area2D

@export var speed: float = 500.0
@export var damage: int = 1

var direction: Vector2 = Vector2.UP

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta

	if position.x < -100 or position.x > 2020 or position.y < -100 or position.y > 1180:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		area.take_damage(damage)
		queue_free()
