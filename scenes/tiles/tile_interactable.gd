class_name TileInteractable
extends TileTrigger

@export var mesh_point: Node3D
@export var subject_animation_on_interact: Subject.Animations


func _on_enter(body: Node3D) -> void:
	var had = bodies_inside.has(body)
	super(body)
	
	if body.is_in_group(body_group) and not had:
		var subject: Subject = body
		
		if Vector2i(subject.target_pos_in_arr) != pos_in_arr:
			return
		
		subject.pause()
		
		await Game.instance.time.tick
		
		subject.look_towards(mesh_point.global_position)
		subject.play_animation(subject_animation_on_interact)
		
		_on_interact(subject)
		subject.unpause()


func _on_interact(subject: Subject) -> void:
	pass


func refresh_animation() -> void:
	if animator == null:
		return
