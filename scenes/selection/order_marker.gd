class_name OrderMarker
extends Node3D

@export var line_tickness: float = 0.1
@export var radial_segments: int = 8

@export_group("References")
@export var label: Label3D
@export var paths_holder: Node3D
@export var sphere_mesh: MeshInstance3D
@export var path_mesh: MeshInstance3D
@export var normal_mat: Material
@export var disabled_mat: Material

var is_disabled: bool = false
var order: int = 1
var id: Vector2i

func _ready() -> void:
	sphere_mesh.mesh = sphere_mesh.mesh.duplicate()
	path_mesh.mesh = path_mesh.mesh.duplicate()
	path_mesh.mesh.material = sphere_mesh.mesh.surface_get_material(0)

func set_disabled(is_it: bool = true) -> void:
	if is_it:
		sphere_mesh.mesh.surface_set_material(0, disabled_mat)
		path_mesh.mesh.surface_set_material(0, disabled_mat)
	else:
		sphere_mesh.mesh.surface_set_material(0, normal_mat)
		path_mesh.mesh.surface_set_material(0, normal_mat)
	
	is_disabled = is_it

func set_preview(is_it: bool = true) -> void:
	set_disabled(is_it)
	path_mesh.visible = not is_it

func set_order(num: int) -> void:
	label.text = str(num)
	order = num

func remove_failed_jumps(path_arr: Array[Vector2i]) -> void:
	if len(path_arr) < 3:
		return
	
	for i in range(len(path_arr)-2, 0, -1):
		var current = path_arr[i]
		var prev = path_arr[i+1]
		var next = path_arr[i-1]
		
		if (current.x == prev.x and prev.x == next.x) or (current.y == prev.y and prev.y == next.y):
			path_arr.remove_at(i)


func generate_path_to(other: Vector2i) -> void:
	set_path(Vector2i(0,0), other - id)

func set_path(from: Vector2i, to: Vector2i) -> void:
	path_mesh.mesh.height = from.distance_to(to)
	path_mesh.position = Vector3(from.x, 0, from.y)
	
	if from.y == to.y:
		var s = sign(to.x - from.x)
		path_mesh.rotation_degrees.x = 0
		path_mesh.rotation_degrees.z = 90 * s
		path_mesh.position.x += path_mesh.mesh.height/2 * s
	else:
		var s = sign(to.y - from.y)
		path_mesh.rotation_degrees.z = 0
		path_mesh.rotation_degrees.x = 90 * s
		path_mesh.position.z += path_mesh.mesh.height/2 * s
	
	path_mesh.show()

func path_visible(visible: bool) -> void:
	path_mesh.visible = visible

func is_on_same_line_at(pos: Vector2i) -> bool:
	return id.x == pos.x or id.y == pos.y

func is_on_same_line_of(other: OrderMarker) -> bool:
	return id.x == other.id.x or id.y == other.id.y

func can_get_to_pos(pos: Vector2i) -> bool:
	if pos.x == id.x:
		var step = sign(id.y-pos.y)
		var pos_i = Vector2i(id)
		for i in range(pos.y, id.y, step):
			pos_i.y = i
			if Game.instance.world.is_pos_solid(pos_i):
				return false
	elif pos.y == id.y:
		var step = sign(id.x-pos.x)
		var pos_i = Vector2i(id)
		for i in range(pos.x, id.x, step):
			pos_i.x = i
			if Game.instance.world.is_pos_solid(pos_i):
				return false
	else:
		return false
	return true

func set_material(new_mat: StandardMaterial3D) -> void:
	var mat = new_mat.duplicate()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var disabled = mat.duplicate()
	mat.stencil_mode = BaseMaterial3D.STENCIL_MODE_XRAY
	mat.stencil_color = mat.albedo_color.lightened(0.5)
	normal_mat = mat
	
	disabled.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	disabled.no_depth_test = true
	disabled.albedo_color.a = 0.4
	disabled_mat = disabled
	
	set_disabled(is_disabled)
