class_name TileTrigger
extends Area3D

@export var body_group: String = "subject"
var bodies_inside: Array[Node3D]

var inside: bool:
	get:
		return not bodies_inside.is_empty()


@export_group("Animation")
@export var animator: AnimationPlayer
@export var enter_animation: String
@export var exit_animation: String



func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	refresh_animation()

func _on_enter(body: Node3D) -> void:
	if body.is_in_group(body_group) and not bodies_inside.has(body):
		var was_empty = bodies_inside.is_empty()
		bodies_inside.append(body)
		
		if was_empty:
			refresh_animation()

func _on_exit(body: Node3D) -> void:
	if body.is_in_group(body_group) and bodies_inside.has(body):
		var wasnt_empty = not bodies_inside.is_empty()
		bodies_inside.erase(body)
		
		if wasnt_empty and bodies_inside.is_empty():
			refresh_animation()

func refresh_animation() -> void:
	if animator == null:
		return
		
	if inside:
		animator.play(enter_animation)
	else:
		animator.play(exit_animation)
