extends Node3D

const Kit = preload("res://core/mesh_kit.gd")
const GATES: Array[Vector3] = [Vector3(-24, 0, -30), Vector3(24, 0, -30), Vector3(24, 0, 30), Vector3(-24, 0, 30)]
const DIRECTIONS: Array[Vector3] = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT]
var gate_materials: Array[StandardMaterial3D] = []


func _ready() -> void:
	var asphalt := Kit.material(Color("343d42"))
	if ResourceLoader.exists("res://assets/materials/yard-asphalt-v1.png"):
		asphalt.albedo_texture = load("res://assets/materials/yard-asphalt-v1.png")
		asphalt.albedo_color = Color("b8b8b8")
		asphalt.uv1_scale = Vector3(24, 30, 1)
		asphalt.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var concrete := Kit.material(Color("8b8c7c"))
	var dark := Kit.material(Color("232c30"), 0.15)
	var yellow := Kit.material(Color("e4bd26"), 0.1)
	var white := Kit.material(Color("d7d5be"))
	var rust := Kit.material(Color("9a6550"), 0.3)
	var blue := Kit.material(Color("536b73"), 0.35)
	Kit.box(self, Vector3(100, 0.5, 136), Vector3(0, -0.25, 0), asphalt, true)
	# Central workshop island makes the racing route physical, not a line on a plane.
	Kit.box(self, Vector3(27, 0.35, 47), Vector3(0, 0.175, 0), concrete, true)
	_warehouse(Vector3(0, 0.35, -1), Vector3(20, 7, 32), dark, concrete, yellow)
	for side in [-1.0, 1.0]:
		Kit.box(self, Vector3(0.16, 0.025, 92), Vector3(side * 33, 0.018, 0), yellow)
		Kit.box(self, Vector3(0.16, 0.025, 62), Vector3(side * 15, 0.018, 0), white)
		for z in range(-60, 61, 20):
			_warehouse(Vector3(side * 45, 0, z), Vector3(16, 8 + abs(z) % 3, 16), blue if z % 40 == 0 else rust, dark, yellow)
		for z in range(-54, 55, 9):
			_barrier(Vector3(side * 35, 0, z), Vector3(1.0, 0.9, 5.4), concrete, yellow, dark)
		for z in [-46.0, 0.0, 46.0]:
			var post := Vector3(side * 34, 0, z)
			Kit.cylinder(self, 0.1, 8, post + Vector3.UP * 4, dark)
			Kit.beam(self, post + Vector3.UP * 8, post + Vector3(-side * 2.5, 8, 0), 0.08, dark)
			Kit.box(self, Vector3(1, 0.12, 0.5), post + Vector3(-side * 2.5, 7.95, 0), white)
	for z in [-56.0, 56.0]:
		Kit.box(self, Vector3(72, 1.2, 0.8), Vector3(0, 0.6, z), concrete, true)
		Kit.box(self, Vector3(72, 0.15, 0.85), Vector3(0, 1.2, z), yellow)
	for index in 4:
		_build_gate(index, yellow, dark)
	# Start grid, parking bays, containers and a small practice ramp.
	for index in 7:
		Kit.box(self, Vector3(0.9, 0.024, 0.7), Vector3(-28 + index * 1.2, 0.02, 34), white if index % 2 == 0 else dark)
	for z in range(-40, 41, 8):
		for side in [-1, 1]:
			Kit.box(self, Vector3(0.1, 0.02, 2.5), Vector3(side * 24, 0.015, z), yellow)
	for index in 3:
		var at := Vector3(-6 + index * 5, 1.3, 48)
		Kit.box(self, Vector3(4.5, 2.6, 8), at, blue if index % 2 == 0 else rust, true)
		for rib in 7:
			Kit.box(self, Vector3(0.08, 2.5, 0.08), at + Vector3(-2.26, 0, -3.5 + rib), dark)
	for index in 6:
		var at := Vector3(15.8, 0, -14 + index * 4)
		Kit.cylinder(self, 0.45, 1.05, at + Vector3.UP * 0.525, yellow)
		Kit.cylinder(self, 0.46, 0.06, at + Vector3.UP * 0.2, dark)
		Kit.cylinder(self, 0.46, 0.06, at + Vector3.UP * 0.85, dark)
	var ramp := Kit.box(self, Vector3(5, 0.2, 8), Vector3(25, 0.65, 8), concrete, true)
	ramp.rotation.x = -0.16
	# Far silhouettes provide depth without a streamed city.
	for index in 9:
		Kit.box(self, Vector3(10, 12 + index % 4 * 6, 10), Vector3(-90 + index * 22, 3, -100), dark)
	_build_crane(Vector3(-38, 0, -67), yellow, dark)
	_build_crane(Vector3(43, 0, 65), yellow, dark)
	Kit.box(self, Vector3(20, 3, 0.16), Vector3(0, 7.1, 15.04), dark)
	_sign("DUMPMONKEY", Vector3(0, 7.6, 15.15), 0, yellow, 120)
	_sign("CREW YARD / 01", Vector3(0, 5.3, 15.12), 0, white, 70)


func _warehouse(at: Vector3, size: Vector3, wall: Material, trim: Material, accent: Material) -> void:
	Kit.box(self, size, at + Vector3.UP * size.y * 0.5, wall, true)
	Kit.box(self, Vector3(size.x + 0.6, 0.28, size.z + 0.6), at + Vector3.UP * size.y, trim)
	for z in [-1.0, 1.0]:
		Kit.box(self, Vector3(size.x * 0.65, size.y * 0.53, 0.07), at + Vector3(0, size.y * 0.29, z * (size.z * 0.5 + 0.04)), trim)
		Kit.box(self, Vector3(size.x * 0.7, 0.12, 0.12), at + Vector3(0, size.y * 0.58, z * (size.z * 0.5 + 0.08)), accent)
	for index in 6:
		Kit.box(self, Vector3(size.x * 0.66, 0.045, 0.1), at + Vector3(0, 0.5 + index * size.y * 0.075, size.z * 0.5 + 0.09), wall)


func _barrier(at: Vector3, size: Vector3, concrete: Material, yellow: Material, dark: Material) -> void:
	Kit.box(self, size, at + Vector3.UP * size.y * 0.5, concrete, true)
	Kit.box(self, Vector3(size.x + 0.02, 0.3, size.z), at + Vector3.UP * 0.6, yellow)
	for index in 4:
		var stripe := Kit.box(self, Vector3(0.025, 0.34, 0.45), at + Vector3(-0.52, 0.6, -2 + index * 1.2), dark)
		stripe.rotation.x = 0.4


func _build_gate(index: int, yellow: Material, dark: Material) -> void:
	var root := Node3D.new()
	root.position = GATES[index]
	if index % 2 == 1:
		root.rotation.y = PI / 2
	add_child(root)
	var mat := Kit.material(Color("e4bd26"))
	gate_materials.append(mat)
	for side in [-1.0, 1.0]:
		Kit.box(root, Vector3(0.24, 5, 0.24), Vector3(side * 7, 2.5, 0), dark)
		Kit.box(root, Vector3(0.4, 1, 0.4), Vector3(side * 7, 1, 0), mat)
	Kit.box(root, Vector3(14.4, 0.7, 0.35), Vector3(0, 5.0, 0), dark)
	_sign("0%d / CHECKPOINT" % (index + 1), root.position + Vector3(0, 5, 0.2), root.rotation.y, yellow, 48)
	Kit.box(root, Vector3(14, 0.025, 0.35), Vector3(0, 0.025, 0), mat)


func highlight_gate(index: int) -> void:
	for i in gate_materials.size():
		gate_materials[i].albedo_color = Color("f9d136") if i == index else Color("6d7774")


func _sign(text: String, at: Vector3, angle: float, mat: StandardMaterial3D, size: int) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = at
	label.rotation.y = angle
	label.font_size = size
	label.pixel_size = 0.009
	label.modulate = mat.albedo_color
	label.outline_size = 0
	add_child(label)


func _build_crane(at: Vector3, yellow: Material, dark: Material) -> void:
	for x in [-1.0, 1.0]:
		Kit.beam(self, at + Vector3(x, 0, 0), at + Vector3(x, 22, 0), 0.13, yellow)
	for y in range(1, 22, 3):
		Kit.beam(self, at + Vector3(-1, y, 0), at + Vector3(1, y + 3, 0), 0.08, yellow)
	Kit.beam(self, at + Vector3(-9, 22, 0), at + Vector3(18, 22, 0), 0.22, yellow)
	Kit.beam(self, at + Vector3(12, 22, 0), at + Vector3(12, 10, 0), 0.035, dark)
