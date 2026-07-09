class_name MainController
extends Node

@export var subject_holder: Node3D
@export var subject_scene: PackedScene

func play() -> void:
	var plan = Game.instance.planning
	var positions: Array[Vector2] = plan.get_position_arr()
	var start_position = Game.instance.world.get_world_pos_of(positions[0])
	var directions_raw: Array[Vector2] = plan.position_to_directions_arr(positions)
	var directions: Array[Vector2] = plan.fill_spaces_in_direction_arr(directions_raw)
	
	for child in subject_holder.get_children():
		child.queue_free()
	
	var subject = spawn_subject_at(start_position)
	subject.set_directions(directions)
	subject.play()

func spawn_subject_at(world_pos: Vector3) -> Subject:
	var subject = subject_scene.instantiate()
	subject_holder.add_child(subject)
	
	subject.global_position = world_pos
	return subject
