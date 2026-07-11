extends Node3D

@export var accessory_colors: Array[Material]
@export var accessories: Array[MultipleMeshs]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for accessory in accessories:
		accessory.hide()
	
	pick_accessories()


func pick_accessories() -> void:
	accessories.shuffle()
	accessory_colors.shuffle()

	var quant = floor(len(accessories) * pow(randf(), 2)) + 1
	var picked: Array[MultipleMeshs] = accessories.slice(0, quant)
	
	var color_idx = 0
	var last_color: Material = accessory_colors[color_idx]
	
	for i in range(0, quant):
		var accessory = picked[i]
		
		if randf() > 0.333:
			last_color = accessory_colors[color_idx]
			color_idx += 1
		
		accessory.set_material(last_color)
		accessory.show()
