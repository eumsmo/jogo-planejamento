class_name MainController
extends Node

@export var subject_holder: Node3D
@export var subject_scene: PackedScene


@export var level_scene: PackedScene

func _ready() -> void:
	Game.instance.world.on_subject_at_end.connect(on_entered_level_end)
	set_level(level_scene)

func play() -> void:
	var plan = Game.instance.planning
	plan.stop()
	
	for child in subject_holder.get_children():
			child.queue_free()
	
	for i in range(0, len(plan.profiles)):
	
		var positions: Array[Vector2] = plan.get_position_arr(i)
		var start_position = Game.instance.world.get_world_pos_of(positions[0])
		var directions_raw: Array[Vector2] = plan.position_to_directions_arr(positions)
		var directions: Array[Vector2] = plan.fill_spaces_in_direction_arr(directions_raw)
		
		var subject = spawn_subject_at(start_position)
		
		await get_tree().process_frame
		subject.teleport_to(start_position)
		subject.set_directions(directions)
		subject.set_exact_points_path(positions)
		
		await Game.instance.time.tick
		subject.play()

func spawn_subject_at(world_pos: Vector3) -> Subject:
	var subject = subject_scene.instantiate()
	subject_holder.add_child(subject)
	return subject


func plan() -> void:
	for child in subject_holder.get_children():
		child.queue_free()
	
	Game.instance.planning.start()


func on_entered_level_end(sub: Subject) -> void:
	if sub == null:
		return
	
	print("End!")
	
	var next_level = Game.instance.world.level.next_level_scene
	if next_level == null:
		#...
		return
	
	set_level(next_level)
	

func set_level(level_scene: PackedScene) -> void:
	var level: Level = level_scene.instantiate()
	Game.instance.world.add_child(level)
	level.position = Vector3.ZERO
	
	Game.instance.world.setup_level(level)
	
	await get_tree().process_frame
	
	Game.instance.planning.setup_profiles(level.subjects_count)
	Game.instance.planning.reset()
	plan()
