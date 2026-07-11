class_name MultipleMeshs
extends Node3D

@export var meshs: Array[MeshInstance3D]

func set_material(mat: Material) -> void:
	for mesh in meshs:
		mesh.set_surface_override_material(0, mat)
