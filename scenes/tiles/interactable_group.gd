extends Node

@export var interactables: Array[TileInteractable]

func _ready() -> void:
	for interactable in interactables:
		interactable.on_interacted.connect(_interactable_changed.bind(interactable))

func _interactable_changed(subject: Subject, interacted: TileInteractable) -> void:
	for interactable in interactables:
		if interactable != interacted:
			interactable.skip_signal = true
			interactable._on_interact(subject)
			interactable.skip_signal = false
