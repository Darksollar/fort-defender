extends ColorRect

signal upgrade_chosen(data: Dictionary)

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var choices_container: VBoxContainer = $CenterContainer/VBoxContainer/ChoicesContainer

func _ready() -> void:
	visible = false


func show_choices(choices: Array[Dictionary]) -> void:
	title_label.text = "Choose an Upgrade"

	# Clear old choices immediately
	for child in choices_container.get_children():
		child.free()

	for upgrade in choices:
		var btn := Button.new()
		btn.text = "%s\n%s" % [upgrade["name"], upgrade["description"]]
		btn.custom_minimum_size = Vector2(300, 70)
		btn.pressed.connect(func() -> void:
			upgrade_chosen.emit(upgrade)
		)
		choices_container.add_child(btn)

	visible = true


func hide_overlay() -> void:
	# Defer freeing — buttons may still be active in the signal chain
	for child in choices_container.get_children():
		child.queue_free()
	visible = false
