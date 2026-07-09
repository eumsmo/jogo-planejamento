class_name Subject
extends Node3D

var directions: Array[Vector2]
var current_idx: int = 0

var last_position: Vector3


func play() -> void:
	current_idx = 0
	last_position = position
	Game.instance.time.tick_progress.connect(tick_progress)

func set_directions(arr: Array[Vector2]) -> void:
	directions = arr

func tick_progress(progress: float, tick: bool) -> void:
	var dir: Vector2= directions[current_idx]
	var target_pos = Game.instance.world.grid_map.cell_size * vec2_to_vec3(dir) + last_position
	
	position = lerp(last_position, target_pos, progress)
	
	if tick:
		next()

func next() -> void:
	if current_idx < len(directions) - 1:
		current_idx += 1
		last_position = position
	else:
		Game.instance.time.tick_progress.disconnect(tick_progress)

func vec2_to_vec3(vec2: Vector2, y_is_zero: bool = true) -> Vector3:
	return Vector3(vec2.x, 0 if y_is_zero else 1, vec2.y)
