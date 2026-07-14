class_name Subject
extends Node3D

var directions: Array[Vector2]
var current_idx: int = 0

var exact_points_on_path: Array[Vector2]
var target_point_pos: Vector3
var points_idx: int = 0
var target_pos_in_arr: Vector2:
	get:
		return exact_points_on_path[points_idx] if points_idx < len(exact_points_on_path) else Vector2(999,999)

var last_position: Vector3

enum Animations { IDLE, WALK, BUTTONS, LEVER }
@export var animation_dict: Dictionary[Animations, String]
@export var animator: AnimationPlayer

var can_go_next: bool = true
var ended_transition: bool = false

func play() -> void:
	current_idx = 0
	last_position = position

	points_idx = -1
	go_to_next_point()

	Game.instance.time.transition_progress.connect(transtion_progress)
	Game.instance.time.tick.connect(next)
	animator.play(animation_dict[Animations.IDLE])
	

func set_directions(arr: Array[Vector2]) -> void:
	directions = arr

func set_exact_points_path(points_path: Array[Vector2]) -> void:
	exact_points_on_path = points_path

func transtion_progress(progress: float) -> void:
	if ended_transition:
		return
	
	animator.play(animation_dict[Animations.WALK])
	
	if last_position == target_point_pos:
		go_to_next_point()
	
	var dir: Vector2 = directions[current_idx]
	var dir3: Vector3 = vec2_to_vec3(dir)
	var target_pos = Game.instance.world.grid_map.cell_size * dir3 + last_position
	
	look_at(global_position - dir3)
	position = lerp(last_position, target_pos, progress)
	
	if progress == 1.0:
		ended_transition = true
		#animator.play(animation_dict[Animations.IDLE])
		pass


func next() -> void:
	if not can_go_next:
		return
	
	if current_idx < len(directions) - 1:
		current_idx += 1
		last_position = position
		ended_transition = false
	else:
		Game.instance.time.transition_progress.disconnect(transtion_progress)
		Game.instance.time.tick.disconnect(next)
		animator.play(animation_dict[Animations.IDLE])

func vec2_to_vec3(vec2: Vector2, y_is_zero: bool = true) -> Vector3:
	return Vector3(vec2.x, 0 if y_is_zero else 1, vec2.y)

func teleport_to(world_pos: Vector3) -> void:
	global_position = world_pos

func pause() -> void:
	if can_go_next:
		Game.instance.time.tick.disconnect(next)
		animator.play(animation_dict[Animations.IDLE])
	can_go_next = false

func unpause() -> void:
	if not can_go_next:
		Game.instance.time.tick.connect(next)
	can_go_next = true

func push_lever() -> void:
	animator.play(animation_dict[Animations.LEVER])

func push_buttons() -> void:
	animator.play(animation_dict[Animations.BUTTONS])

func play_animation(animation: Animations) -> void:
	animator.play(animation_dict[animation])

func look_towards(pos: Vector3) -> void:
	var dir = pos - global_position
	dir.y = 0
	look_at(global_position - dir)

func go_to_next_point() -> void:
	points_idx = clamp(points_idx + 1, 0, len(exact_points_on_path))
	if points_idx == len(exact_points_on_path):
		target_point_pos = Vector3(9999,9999,9999)
	else:
		target_point_pos = Game.instance.world.get_world_pos_of(exact_points_on_path[points_idx])

func die() -> void:
	can_go_next = false
	
	Game.instance.time.transition_progress.disconnect(transtion_progress)
	Game.instance.time.tick.disconnect(next)
	animator.play(animation_dict[Animations.IDLE])
	
	await get_tree().create_timer(0.5).timeout
	
	queue_free()
