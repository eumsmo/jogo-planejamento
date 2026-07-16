extends Node

signal changed(val: bool)
var last_val: bool = false

@export var buttons: Array[TileTrigger]

func _ready() -> void:
	for button in buttons:
		button.mode_changed.connect(on_change)

func on_change(_val: bool) -> void:
	var val = false
	for button in buttons:
		if button.inside:
			val = true
			break
	
	if val != last_val:
		changed.emit(val)
		last_val = val
	
