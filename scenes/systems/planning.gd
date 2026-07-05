extends Node3D

@export var marker_scene: PackedScene

var last_marker: OrderMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.instance.selector.cell_clicked.connect(_handle_grid_cell_clicked)

func _handle_grid_cell_clicked(cell_info: World.GridCellInfo) -> void:
	if cell_info.solid:
		return
	
	if get_marker_at(cell_info.arr_pos) != null:
		return
	
	var pos = cell_info.world_pos
	
	var marker: OrderMarker = marker_scene.instantiate()
	marker.id = cell_info.arr_pos
	add_child(marker)
	
	marker.global_position = pos
	
	if last_marker != null:
		marker.set_order(last_marker.order + 1)
		last_marker.generate_paths_to(marker.id)
	
	last_marker = marker

func get_marker_at(id: Vector2i) -> OrderMarker:
	for marker in get_children():
		if marker.id == id:
			return marker
	return null
