class_name Planning
extends Node3D

@export var marker_materials: Array[Material]
var current_marker_material: Material:
	get:
		return marker_materials[profile_idx]

@export var marker_scene: PackedScene

@export var preview_marker: OrderMarker
var first_marker: OrderMarker:
	get:
		return current_profile.get_child(0)
var last_marker: OrderMarker:
	get:
		return current_profile.get_child(-1)

var profiles: Array[Node3D]
var profile_idx: int = 0
var current_profile: Node3D:
	get:
		return profiles[profile_idx]


var running: bool = true

signal delete_confirmation_requested
signal _delete_confirmation_answered(result: bool)


signal on_profiles_changed(quant: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.instance.selector.cell_clicked.connect(_handle_grid_cell_clicked)
	Game.instance.selector.cell_hovered.connect(_handle_grid_cell_hover)
	preview_marker.set_preview(true)
	preview_marker.set_order(2)
	
	setup_profiles(1)

func set_starting_marker() -> void:
	var starting_id = Game.instance.world.start_id
	var global_pos = Game.instance.world.get_world_pos_of(starting_id)
	
	for profile in profiles:
		var first: OrderMarker = profile.get_child(0)
		first.id = starting_id
		first.global_position = global_pos


func setup_profiles(quantity: int) -> void:
	for profile in profiles:
		profile.queue_free()
	profiles.clear()
	
	for i in range(0, quantity):
		var profile = Node3D.new()
		var first = marker_scene.instantiate()
		first.set_material(marker_materials[i])
		add_child(profile)
		profile.add_child(first)
		
		profile.hide()
		profiles.append(profile)
	
	profile_idx = 0
	update_preview()
	current_profile.show()
	on_profiles_changed.emit(quantity)
	

func update_preview() -> void:
	if last_marker != null:
		preview_marker.set_order(last_marker.order + 1)
	preview_marker.set_material(current_marker_material)


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
	
	if cell_info.solid:
		return
	
	if get_marker_at(cell_info.arr_pos) != null:
		if button == 2:
			call_to_delete_marker_at(cell_info.arr_pos)
		return
	
	if not last_marker.can_get_to_pos(cell_info.arr_pos) or button != 1:
		return
	
	var pos = cell_info.world_pos
	var marker: OrderMarker = marker_scene.instantiate()
	marker.id = cell_info.arr_pos
	marker.set_material(current_marker_material)
	
	if last_marker != null:
		marker.set_order(last_marker.order + 1)
		preview_marker.set_order(marker.order + 1)
		last_marker.generate_path_to(marker.id)
	
	current_profile.add_child(marker)
	marker.global_position = pos
	
	last_marker = marker
	
	_handle_grid_cell_hover(cell_info)

func get_marker_at(id: Vector2i) -> OrderMarker:
	for marker in current_profile.get_children():
		if marker.id == id:
			return marker
	return null

func get_marker_of_order(order: int) -> OrderMarker:
	for marker in current_profile.get_children():
		if marker.order == order and marker != preview_marker:
			return marker
	return null

func get_position_arr(profile_idx: int = 0) -> Array[Vector2]:
	var profile = profiles[profile_idx]
	
	var markers: Array[OrderMarker]
	markers.resize(profile.get_child_count())
	
	for marker in profile.get_children():
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

func reset() -> void:
	for profile in profiles:
		for marker in profile.get_children():
			if marker.get_index() != 0:
				marker.queue_free()
	
		profile.get_child(0).path_visible(false)
	preview_marker.set_order(2)
	set_starting_marker()

func call_to_delete_marker_at(location: Vector2i) -> void:
	var marker_to_delete = get_marker_at(location)
	if marker_to_delete == first_marker or marker_to_delete == preview_marker:
		return
	
	var order = marker_to_delete.order
	var delete_markers: Array[OrderMarker]
	
	for marker in current_profile.get_children():
		if marker.order >= order and marker != preview_marker:
			delete_markers.append(marker)
	
	var quant_to_delete = len(delete_markers)
	var will_delete = true
	
	if quant_to_delete > 1:
		delete_confirmation_requested.emit()
		will_delete = await _delete_confirmation_answered
	
	if will_delete:
		for marker in delete_markers:
			marker.queue_free()
		
		var previous = get_marker_of_order(order - 1)
		if previous != null:
			last_marker = previous
			previous.path_visible(false)
		
		preview_marker.set_order(order)
	

func answer_delete_request(val: bool) -> void:
	_delete_confirmation_answered.emit(val)

func change_current_profile(idx: int) -> void:
	if idx == profile_idx:
		return
	
	var previous = profiles[profile_idx]
	previous.hide()
	
	profile_idx = idx
	current_profile.show()
	update_preview()
