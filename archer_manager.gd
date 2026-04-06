extends Node

@export var archer_scene: PackedScene
@export var projectile_scene: PackedScene
@export var archer_container_path: NodePath
@export var projectile_container_path: NodePath
@export var formation_anchor_path: NodePath
@export var starting_archers: int = 3

@export_group("Formation Data")
@export var row_counts: Array[int] = [3, 4, 5, 8]
@export var row_widths: Array[float] = [640.0, 720.0, 800.0, 980.0]
@export var row_y_offsets: Array[float] = [0.0, -32.0, 32.0, 64.0]

var slots: Array[Vector2] = []
var spawn_order: Array[int] = []
var occupied: Array[bool] = []

var _archer_container: Node2D
var _projectile_container: Node2D
var _formation_anchor: Marker2D


func _ready() -> void:
	_resolve_references()
	_generate_slots()
	_build_spawn_order()
	_init_occupied_array()
	for _i in range(starting_archers):
		add_archer()


func _resolve_references() -> void:
	_archer_container = get_node(archer_container_path)
	_projectile_container = get_node(projectile_container_path)
	_formation_anchor = get_node(formation_anchor_path)


func _generate_slots() -> void:
	var anchor_pos = _formation_anchor.global_position
	for row in range(row_counts.size()):
		var count = row_counts[row]
		var width = row_widths[row]
		var y_offset = row_y_offsets[row]
		if count > 1:
			for i in range(count):
				var x = anchor_pos.x - width / 2.0 + (width / float(count - 1)) * i
				var y = anchor_pos.y + y_offset
				slots.append(Vector2(x, y))
		else:
			slots.append(Vector2(anchor_pos.x, anchor_pos.y + y_offset))


func _build_spawn_order() -> void:
	var slot_index = 0
	for row in range(row_counts.size()):
		var count = row_counts[row]
		if row == 0:
			for i in range(count):
				spawn_order.append(slot_index + i)
		else:
			var indices = []
			for i in range(count):
				indices.append(i)
			var mid = (count - 1) / 2.0
			indices.sort_custom(func(a, b):
				return abs(a - mid) < abs(b - mid))
			for i in indices:
				spawn_order.append(slot_index + i)
		slot_index += count


func _init_occupied_array() -> void:
	occupied.assign([])
	for _i in range(slots.size()):
		occupied.append(false)


func has_free_slot() -> bool:
	for slot_idx in spawn_order:
		if not occupied[slot_idx]:
			return true
	return false


func add_archer(base_dmg: int = 1) -> bool:
	var slot_idx = -1
	for i in spawn_order:
		if not occupied[i]:
			slot_idx = i
			break
	if slot_idx == -1:
		return false

	var archer = archer_scene.instantiate()
	_archer_container.add_child(archer)
	archer.global_position = slots[slot_idx]
	archer.projectile_container = _projectile_container
	archer.projectile_scene = projectile_scene
	archer.slot_index = slot_idx
	archer.base_damage = base_dmg
	occupied[slot_idx] = true
	return true
