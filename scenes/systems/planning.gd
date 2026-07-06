extends Node3D

@export var marker_scene: PackedScene

@export var preview_marker: OrderMarker
@export var last_marker: OrderMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.instance.selector.cell_clicked.connect(_handle_grid_cell_clicked)
	Game.instance.selector.cell_hovered.connect(_handle_grid_cell_hover)
	preview_marker.set_preview(true)
	preview_marker.set_order(last_marker.order + 1)
	
	await get_tree().process_frame
	last_marker.id = Vector2i(7,7)
	last_marker.global_position = Game.instance.world.get_world_pos_of(last_marker.id)


func _handle_grid_cell_hover(cell_info: World.GridCellInfo) -> void:
	if cell_info == null or not last_marker.can_get_to_pos(cell_info.arr_pos) or cell_info.arr_pos == last_marker.id:
		preview_marker.hide()
		last_marker.path_visible(false)
		return
	
	preview_marker.global_position = cell_info.world_pos
	preview_marker.id = cell_info.arr_pos
	preview_marker.show()
	last_marker.generate_path_to(preview_marker.id)
	last_marker.path_visible(true)


func _handle_grid_cell_clicked(cell_info: World.GridCellInfo) -> void:
	if cell_info.solid:
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
