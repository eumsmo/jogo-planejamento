class_name Game
extends Node3D

static var instance: Game

@export var world: World
@export var selector: GridSelector
@export var time: TimeManager
@export var planning: Planning
@export var controller: MainController

func _init() -> void:
	instance = self
