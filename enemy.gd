extends Area2D

signal died(drop_position: Vector2)

@export var speed: float = 80.0
@export var hp: int = 3
@export var wall_y: float = 580.0
@export var attack_damage: int = 3
@export var attack_interval: float = 1.0

var fort_zone: Node = null
var attacking: bool = false
var attack_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")

func _process(delta: float) -> void:
	if attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			if fort_zone != null and fort_zone.has_method("take_damage"):
				fort_zone.take_damage(attack_damage)
			attack_timer = attack_interval
		return

	position.y += speed * delta

	if position.y >= wall_y - 14.0:
		position.y = wall_y - 14.0
		attacking = true
		attack_timer = 0.0

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	died.emit(global_position)
	queue_free()
