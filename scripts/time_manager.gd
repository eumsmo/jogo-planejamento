class_name TimeManager
extends Node

var each_tick_time: float = 0.5
var tick_timer: float = 0.0

signal tick
signal tick_progress(progress: float, ticked: bool)

func _physics_process(delta: float) -> void:
	tick_timer += delta
	
	if tick_timer > each_tick_time:
		tick_timer = each_tick_time
	
	var progress = tick_timer/each_tick_time
	var will_tick = progress == 1
	
	tick_progress.emit(progress, will_tick)
	if will_tick:
		tick.emit()
		tick_timer = 0.0
