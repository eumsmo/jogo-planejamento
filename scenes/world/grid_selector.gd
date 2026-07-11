class_name GridSelector
extends Node

@export var selection_visualization: Node3D
@export var camera: Camera3D

var current_cell: World.GridCellInfo
var current_pos: Vector2i

signal cell_clicked(info: World.GridCellInfo, button: int)
signal cell_unpressed(cell: World.GridCellInfo, pos: Vector2i)
signal cell_hovered(cell: World.GridCellInfo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_check_for_cell_under()
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if current_cell != null and event.is_pressed():
			cell_clicked.emit(current_cell,event.button_index)


func _check_for_cell_under() -> void:
	var mouse = camera.get_viewport().get_mouse_position()
	
	var target_plane = Plane(Vector3(0, 1, 0), Game.instance.world.global_position.z)
	var world_pos = target_plane.intersects_ray(
		camera.project_ray_origin(mouse),
		camera.project_ray_normal(mouse)
	)
	
	if world_pos == null:
		current_cell = null
		selection_visualization.hide()
		return
	
	world_pos.y = Game.instance.world.global_position.y
	
	var cell = Game.instance.world.get_grid_at(world_pos)
	if cell == current_cell:
		return
	
	current_cell = cell
	
	if current_cell != null and not Game.instance.world.is_pos_solid(current_cell.arr_pos):
		var pos = current_cell.world_pos
		pos.y -= 0.45
		selection_visualization.global_position = pos
		selection_visualization.show()
	else:
		selection_visualization.hide()
	
	cell_hovered.emit(current_cell)
