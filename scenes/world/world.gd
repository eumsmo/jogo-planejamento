class_name World
extends Node3D

class GridCellInfo:
	var item: int
	var arr_pos: Vector2i
	var world_pos: Vector3
	var solid: bool

@export var grid_map: GridMap

var grid_array: Array[Array] = []

# Important when setting an array by gridmap only
var gridmap_x_offset: int = 0
var gridmap_y_offset: int = 0

var last_checked_cell: GridCellInfo


var a_star: AStarGrid2D


func _ready() -> void:
	set_array_by_gridmap()

func set_array_by_gridmap() -> void:
	var bounds = get_gridmap_bounds(grid_map)
	gridmap_x_offset = bounds[0].x
	gridmap_y_offset = bounds[0].y
	
	var size = Vector2(bounds[1].x - bounds[0].x + 1, bounds[1].y - bounds[0].y + 1)
	set_gridarray_size(size, true)
	
	var cells = grid_map.get_used_cells()
	
	a_star = AStarGrid2D.new()
	a_star.region = Rect2i(0, 0, size.x, size.y)
	a_star.cell_size = Vector2(1,1)
	a_star.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a_star.jumping_enabled = true
	a_star.update()
	
	for cell in cells:
		var pos_in_array = gridmap_pos_to_gridarray(cell)
		var item = grid_map.get_cell_item(cell)
		grid_array[pos_in_array.y][pos_in_array.x] = item
		if is_item_solid(item):
			a_star.set_point_solid(pos_in_array)
	
	a_star.update()

func is_item_solid(item: int) -> bool:
	return item == 0

func get_gridmap_bounds(map: GridMap) -> Array[Vector2]:
	var cells = grid_map.get_used_cells()
	var min = Vector2(INF,INF)
	var max = Vector2(-INF,-INF)
	
	for cell in cells:
		if cell.x < min.x:
			min.x = cell.x
		if cell.x > max.x:
			max.x = cell.x
		if cell.z < min.y:
			min.y = cell.z
		if cell.z > max.y:
			max.y = cell.z
	
	return [min,max]

func set_gridarray_size(size: Vector2, fill_negative: bool = false) -> void:
	grid_array.resize(size.y)
	for i in range(0,size.y):
		if grid_array[i] == null:
			grid_array[i] = []
		grid_array[i].resize(size.x)
		
		if fill_negative:
			grid_array[i].fill(-1)

func gridmap_pos_to_gridarray(prev_pos: Vector3i) -> Vector2i:
	var pos = Vector2i(prev_pos.x, prev_pos.z)
	pos.x -= gridmap_x_offset
	pos.y -= gridmap_y_offset
	return pos

func is_in_array_bounds(pos: Vector2) -> bool:
	if pos.x < 0 or pos.x >= len(grid_array[0]):
		return false
	return pos.y >= 0 and pos.y < len(grid_array)


func get_grid_at(world_pos: Vector3) -> GridCellInfo:
	var local_pos = grid_map.to_local(world_pos)
	var gridmap_pos = grid_map.local_to_map(local_pos)
	var gridarray_pos = gridmap_pos_to_gridarray(gridmap_pos)
	
	if not is_in_array_bounds(gridarray_pos):
		return null
	
	if last_checked_cell != null and last_checked_cell.arr_pos == gridarray_pos:
		return last_checked_cell
	
	var info = GridCellInfo.new()
	info.arr_pos = gridarray_pos
	info.world_pos = grid_map.map_to_local(gridmap_pos)
	info.item = grid_array[gridarray_pos.y][gridarray_pos.x]
	info.solid = is_item_solid(info.item)
	
	
	last_checked_cell = info
	
	return info

func get_world_pos_of(array_pos: Vector2i) -> Vector3:
	return grid_map.local_to_map(Vector3(array_pos.x, 0, array_pos.y))
