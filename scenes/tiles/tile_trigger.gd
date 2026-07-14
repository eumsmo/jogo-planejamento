@tool
class_name TileTrigger
extends Area3D

@export_tool_button("Reposition Tile") var my_button = in_editor_reposition

@export var pos_in_arr: Vector2i
@export var body_group: String = "subject"
var bodies_inside: Array[Node3D]

var inside: bool:
	get:
		return not bodies_inside.is_empty()


@export_group("Animation")
@export var animator: AnimationPlayer
@export var enter_animation: String
@export var exit_animation: String

signal entered(body: Node3D)
signal left(body: Node3D)


func in_editor_reposition():
	var gridmap: GridMap = null
	
	for sibling in get_parent().get_children():
		if sibling is GridMap:
			gridmap = sibling
			break
	
	if gridmap == null:
		return
	
	var bounds = get_gridmap_bounds(gridmap)
	var actual_coords = pos_in_arr + Vector2i(bounds[0])
	
	var local_pos = gridmap.map_to_local(Vector3i(actual_coords.x, 0, actual_coords.y))
	var global = gridmap.to_global(local_pos)
	global.y = gridmap.global_position.y
	global_position = global

func get_gridmap_bounds(map: GridMap) -> Array[Vector2]:
	var cells = map.get_used_cells()
	var min = Vector2(INF,INF)
	var max = Vector2(-INF,-INF)
	
	for cell in cells:
		if cell.x < min.x:
			min.x = cell.x
		if cell.x > max.x:
			max.x = cell.x
		if cell.z < min.y:
			min.y = cell.z
		if cell.z > max.y:
			max.y = cell.z
	
	return [min,max]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)
	refresh_animation()
	
	await get_tree().process_frame
	await get_tree().process_frame
	global_position = Game.instance.world.get_world_pos_of(pos_in_arr)
	
func set_pos_in_arr(pos: Vector2i) -> void:
	pos_in_arr = pos
	global_position = Game.instance.world.get_world_pos_of(pos_in_arr)

func _on_enter(body: Node3D) -> void:
	if body.is_in_group(body_group) and not bodies_inside.has(body):
		var was_empty = bodies_inside.is_empty()
		bodies_inside.append(body)
		entered.emit(body)
		
		if was_empty:
			refresh_animation()

func _on_exit(body: Node3D) -> void:
	if body.is_in_group(body_group) and bodies_inside.has(body):
		var wasnt_empty = not bodies_inside.is_empty()
		bodies_inside.erase(body)
		left.emit(body)
		
		if wasnt_empty and bodies_inside.is_empty():
			refresh_animation()

func refresh_animation() -> void:
	if animator == null:
		return
		
	if inside:
		animator.play(enter_animation)
	else:
		animator.play(exit_animation)
