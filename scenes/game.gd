class_name Game
extends Node3D

static var instance: Game

@export var world: World
@export var selector: GridSelector

func _init() -> void:
	instance = self
