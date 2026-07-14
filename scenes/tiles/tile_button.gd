@tool
extends TileInteractable

@export var ticks: int = 3
var ticks_till_off: int = 0
var is_on: bool = false

signal value_changed(val: bool)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super()
	button_animation()
	
	value_changed.connect(print)

func _on_interact(subject: Subject) -> void:
	is_on = true
	
	if ticks_till_off == 0:
		Game.instance.time.tick.connect(_handle_ticks)
	ticks_till_off = ticks

	
	value_changed.emit(is_on)
	button_animation()

func _handle_ticks() -> void:
	if ticks_till_off > 0:
		ticks_till_off -= 1
	else:
		ticks_till_off = 0
		Game.instance.time.tick.disconnect(_handle_ticks)
		is_on = false
		value_changed.emit(is_on)
		button_animation()


func button_animation() -> void:
	if animator == null:
		return
