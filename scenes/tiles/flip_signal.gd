extends Node

signal flipped(val: bool)

func receiver(val: bool) -> void:
	flipped.emit(not val)
