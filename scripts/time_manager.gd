class_name TimeManager
extends Node

@export var transition_time: float = 0.5
var transition_timer: float = 0.0

@export var each_tick_time: float = 0.1
var tick_timer: float = 0.0

var is_transitioning: bool = false

signal tick
signal tick_progress(progress: float, ticked: bool)
signal transition_progress(progress: float)

func _physics_process(delta: float) -> void:
	if is_transitioning:
		_handle_transition(delta)
	else:
		_handle_tick_timer(delta)

func _handle_tick_timer(delta: float) -> void:
	tick_timer += delta
	
	if tick_timer > each_tick_time:
		tick_timer = each_tick_time
	
	var progress = tick_timer/each_tick_time
	var will_tick = progress == 1
	
	tick_progress.emit(progress, will_tick)
	if will_tick:
		tick.emit()
		tick_timer = 0.0
		is_transitioning = true

func _handle_transition(delta: float) -> void:
	transition_timer += delta
	
	if transition_timer > transition_time:
		transition_timer = transition_time
	
	var progress = transition_timer/transition_time
	
	transition_progress.emit(progress)
	
	if progress == 1.0:
		transition_timer = 0.0
		#is_transitioning = false
		tick.emit()
		tick_timer = 0.0
