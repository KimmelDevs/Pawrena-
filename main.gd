extends Node2D

@onready var tilemap = $Grid
@onready var units = $Units

@onready var cat_scene_2 = preload("res://cat_unit.tscn")
@onready var cat_scene_1 = preload("res://cat_unit_2.tscn")

var selected_unit_scene : PackedScene = null

func _ready():
	selected_unit_scene = cat_scene_2

	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_unit_scene == null:
			print("No unit selected!")
			return

		var mouse_pos = tilemap.get_local_mouse_position()
		var cell = tilemap.local_to_map(mouse_pos)
		var world_pos = tilemap.map_to_local(cell) + Vector2(8, 8)

		var unit = selected_unit_scene.instantiate()
		unit.position = world_pos
		units.add_child(unit)

func select_unit(index: int):
	if index == 0:
		selected_unit_scene = cat_scene_1
	elif index == 1:
		selected_unit_scene = cat_scene_2
	else:
		print("Invalid unit index")


func _on_cat_button_1_pressed() -> void:
	selected_unit_scene = cat_scene_1 
	 # Replace with function body.


func _on_cat_button_2_pressed() -> void:
	selected_unit_scene = cat_scene_2 
 # Replace with function body.
