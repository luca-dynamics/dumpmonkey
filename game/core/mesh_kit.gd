class_name MeshKit
extends RefCounted

static func material(color: Color, metallic: float = 0.0, roughness: float = 0.7) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metallic
	result.roughness = roughness
	return result


static func box(parent: Node3D, size: Vector3, at: Vector3, mat: Material, collision: bool = false) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return instance(parent, mesh, at, mat, collision)


static func sphere(parent: Node3D, size: Vector3, at: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radial_segments = 16
	mesh.rings = 8
	mesh.radius = 0.5
	mesh.height = 1.0
	var result := instance(parent, mesh, at, mat)
	result.scale = size
	return result


static func cylinder(parent: Node3D, radius: float, height: float, at: Vector3, mat: Material, top: float = -1.0) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius if top < 0.0 else top
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	return instance(parent, mesh, at, mat)


static func beam(parent: Node3D, from: Vector3, to: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	var result := cylinder(parent, radius, from.distance_to(to), (from + to) * 0.5, mat)
	var direction := (to - from).normalized()
	result.quaternion = Quaternion(Vector3.UP, direction)
	return result


static func instance(parent: Node3D, mesh: Mesh, at: Vector3, mat: Material, collision: bool = false) -> MeshInstance3D:
	var result := MeshInstance3D.new()
	result.mesh = mesh
	result.material_override = mat
	result.position = at
	parent.add_child(result)
	if collision:
		result.create_trimesh_collision()
	return result
