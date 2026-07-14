class_name Planning
extends Node3D

@export var marker_scene: PackedScene

@export var preview_marker: OrderMarker
@export var last_marker: OrderMarker

var running: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.instance.selector.cell_clicked.connect(_handle_grid_cell_clicked)
	Game.instance.selector.cell_hovered.connect(_handle_grid_cell_hover)
	preview_marker.set_preview(true)
	preview_marker.set_order(last_marker.order + 1)
	
	await get_tree().process_frame
	set_starting_marker()
	

func set_starting_marker() -> void:
	last_marker.id = Game.instance.world.start_id
	last_marker.global_position = Game.instance.world.get_world_pos_of(last_marker.id)


func _handle_grid_cell_hover(cell_info: World.GridCellInfo) -> void:
	if not running:
		return
	
	if cell_info == null or not last_marker.can_get_to_pos(cell_info.arr_pos) or cell_info.arr_pos == last_marker.id or get_marker_at(cell_info.arr_pos) != null:
		preview_marker.hide()
		last_marker.path_visible(false)
		return
	
	preview_marker.global_position = cell_info.world_pos
	preview_marker.id = cell_info.arr_pos
	preview_marker.show()
	last_marker.generate_path_to(preview_marker.id)
	last_marker.path_visible(true)

func _handle_grid_cell_clicked(cell_info: World.GridCellInfo, button: int) -> void:
	if not running:
		return
	
	if cell_info.solid or button != 1:
		return
	
	if get_marker_at(cell_info.arr_pos) != null:
		return
	
	if not last_marker.can_get_to_pos(cell_info.arr_pos):
		return
	
	var pos = cell_info.world_pos
	var marker: OrderMarker = marker_scene.instantiate()
	marker.id = cell_info.arr_pos
	add_child(marker)
	
	marker.global_position = pos
	
	if last_marker != null:
		marker.set_order(last_marker.order + 1)
		preview_marker.set_order(marker.order + 1)
		last_marker.generate_path_to(marker.id)
	
	last_marker = marker
	
	_handle_grid_cell_hover(cell_info)

func get_marker_at(id: Vector2i) -> OrderMarker:
	for marker in get_children():
		if marker.id == id and marker != preview_marker:
			return marker
	return null

func get_position_arr() -> Array[Vector2]:
	var markers: Array[OrderMarker]
	markers.resize(get_child_count()-1)
	
	for marker in get_children():
		if marker != preview_marker:
			markers[marker.order - 1] = marker
	
	var positions: Array[Vector2]
	positions.resize(len(markers))
	for i in range(0, len(markers)):
		positions[i] = Vector2(markers[i].id)
	
	return positions #markers.map(func(v: OrderMarker): return v.id)

func position_to_directions_arr(position_arr: Array[Vector2]) -> Array[Vector2]:
	var directions: Array[Vector2]
	if len(position_arr) < 2:
		return []
	
	var previous_pos = position_arr[0]
	for i in range(1, len(position_arr)):
		var current_pos = position_arr[i]
		directions.append(current_pos - previous_pos)
		previous_pos = current_pos
	
	return directions

func fill_spaces_in_direction_arr(direction_arr: Array[Vector2]) -> Array[Vector2]:
	var filled_directions: Array[Vector2]
	
	for i in range(0, len(direction_arr)):
		var dir_axis = 'x' if direction_arr[i].x != 0 else 'y'
		var val = direction_arr[i][dir_axis]
		
		var v = Vector2.ZERO
		v[dir_axis] = sign(val)
		
		for j in range(0, abs(val)):
			filled_directions.append(v)
	
	return filled_directions


func stop() -> void:
	hide()
	running = false

func start() -> void:
	show()
	running = true
	
