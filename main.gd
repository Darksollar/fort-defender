extends Node2D

@onready var fort_zone = $WorldNode2D/FortZone
@onready var fort_health_label = $HUD/FortHealthLabel

func _ready() -> void:
	fort_zone.health_changed.connect(_on_fort_health_changed)
	fort_zone.destroyed.connect(_on_fort_destroyed)
	_on_fort_health_changed(fort_zone.health, fort_zone.max_health)

func _on_fort_health_changed(current: int, max_health: int) -> void:
	fort_health_label.text = "Fort HP: %d / %d" % [current, max_health]

func _on_fort_destroyed() -> void:
	fort_health_label.text = "FORT DESTROYED"
	get_tree().paused = true
