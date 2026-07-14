class_name Level
extends Node3D

@export var start_at: Vector2i
@export var end_at: Vector2i
@export var grid_map: GridMap

func get_start_pos() -> Vector3:
	return grid_map.to_global(grid_map.map_to_local(Vector3i(start_at.x, 0, start_at.y)))

func get_end_pos() -> Vector3:
	return grid_map.to_global(grid_map.map_to_local(Vector3i(end_at.x, 0, end_at.y)))
