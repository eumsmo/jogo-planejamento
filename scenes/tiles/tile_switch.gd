@tool
extends TileInteractable

@export_group("Animation")
@export var off_animation: String
@export var on_animation: String
@export var off_animation_is_reversed_on: bool = false

var is_on: bool = false

signal value_changed(val: bool)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super()
	switch_animation()

func _on_interact(subject: Subject) -> void:
	if is_on:
		is_on = false
	else:
		is_on = true
	
	if not skip_signal:
		value_changed.emit(is_on)
	
	switch_animation()


func switch_animation() -> void:
	if animator == null:
		return
	
	if is_on and not on_animation.is_empty():
		animator.play(on_animation)
	elif not is_on:
		if not off_animation.is_empty():
			animator.play(off_animation)
		elif off_animation_is_reversed_on:
			animator.play_backwards(on_animation)
