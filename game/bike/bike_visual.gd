extends Node3D

const Kit = preload("res://core/mesh_kit.gd")
var wheels: Array[Node3D] = []
var rider: Node3D
var steering: Node3D


func _ready() -> void:
	var yellow := Kit.material(Color("efc516"), 0.3, 0.35)
	var black := Kit.material(Color("14191c"), 0.15, 0.65)
	var rubber := Kit.material(Color("16191b"), 0.0, 0.95)
	var metal := Kit.material(Color("78858a"), 0.8, 0.3)
	var dark_metal := Kit.material(Color("30383d"), 0.7, 0.45)
	var gold := Kit.material(Color("b58b40"), 0.65, 0.4)
	for z in [-0.82, 0.78]:
		var wheel := Node3D.new()
		wheel.position = Vector3(0, 0.37, z)
		add_child(wheel)
		wheels.append(wheel)
		var tire := Kit.cylinder(wheel, 0.36, 0.24, Vector3.ZERO, rubber)
		tire.rotation.z = PI / 2
		for side in [-1.0, 1.0]:
			var rim := Kit.cylinder(wheel, 0.27, 0.015, Vector3(side * 0.125, 0, 0), black)
			rim.rotation.z = PI / 2
			var disc := Kit.cylinder(wheel, 0.19, 0.012, Vector3(side * 0.137, 0, 0), metal)
			disc.rotation.z = PI / 2
			for spoke in 6:
				var angle := spoke * TAU / 6.0
				Kit.beam(wheel, Vector3(side * 0.15, 0, 0), Vector3(side * 0.15, sin(angle) * 0.26, cos(angle) * 0.26), 0.017, gold)
	Kit.beam(self, Vector3(-0.16, 0.45, 0.77), Vector3(-0.16, 0.62, 0.0), 0.055, dark_metal)
	Kit.beam(self, Vector3(0.16, 0.45, 0.77), Vector3(0.16, 0.62, 0.0), 0.055, dark_metal)
	for side in [-1.0, 1.0]:
		Kit.beam(self, Vector3(side * 0.17, 0.37, -0.82), Vector3(side * 0.17, 1.12, -0.52), 0.04, gold)
		Kit.beam(self, Vector3(side * 0.19, 0.6, 0.35), Vector3(side * 0.15, 1.05, -0.4), 0.035, dark_metal)
		Kit.beam(self, Vector3(side * 0.19, 0.6, 0.35), Vector3(side * 0.18, 0.99, 0.38), 0.035, dark_metal)
	Kit.sphere(self, Vector3(0.58, 0.39, 0.68), Vector3(0, 1.04, -0.21), yellow)
	Kit.box(self, Vector3(0.39, 0.1, 0.6), Vector3(0, 1.02, 0.38), black)
	Kit.sphere(self, Vector3(0.41, 0.17, 0.41), Vector3(0, 1.0, 0.67), yellow)
	Kit.box(self, Vector3(0.38, 0.12, 0.22), Vector3(0, 0.96, 0.87), black)
	Kit.box(self, Vector3(0.27, 0.05, 0.02), Vector3(0, 0.97, 0.99), Kit.material(Color("e35435")))
	Kit.box(self, Vector3(0.31, 0.29, 0.35), Vector3(0, 0.65, -0.08), dark_metal)
	for fin in 5:
		Kit.box(self, Vector3(0.4, 0.018, 0.33), Vector3(0, 0.59 + fin * 0.045, -0.08), metal)
	Kit.beam(self, Vector3(0.21, 0.55, -0.25), Vector3(0.3, 0.33, 0.05), 0.035, metal)
	Kit.beam(self, Vector3(0.3, 0.33, 0.05), Vector3(0.34, 0.41, 0.59), 0.055, dark_metal)
	Kit.beam(self, Vector3(-0.28, 0.63, 0.21), Vector3(0.28, 0.63, 0.21), 0.025, metal)
	steering = Node3D.new()
	steering.position = Vector3(0, 1.14, -0.51)
	add_child(steering)
	Kit.beam(steering, Vector3(-0.42, 0.07, 0), Vector3(0.42, 0.07, 0), 0.025, metal)
	for side in [-1.0, 1.0]:
		Kit.beam(steering, Vector3(side * 0.29, 0.07, 0), Vector3(side * 0.45, 0.07, 0), 0.037, black)
	Kit.box(steering, Vector3(0.23, 0.22, 0.14), Vector3(0, -0.08, -0.08), yellow)
	Kit.box(steering, Vector3(0.16, 0.13, 0.02), Vector3(0, -0.08, -0.16), Kit.material(Color("fff0bd")))
	_build_rider(black, yellow)


func _build_rider(black: Material, yellow: Material) -> void:
	rider = Node3D.new()
	add_child(rider)
	var skin := Kit.material(Color("d9ac54"))
	var hair := Kit.material(Color("6c421e"))
	var sole := Kit.material(Color("363b39"))
	Kit.sphere(rider, Vector3(0.5, 0.6, 0.34), Vector3(0, 1.44, 0.19), black)
	Kit.sphere(rider, Vector3(0.4, 0.27, 0.3), Vector3(0, 1.12, 0.32), black)
	Kit.box(rider, Vector3(0.035, 0.42, 0.025), Vector3(0, 1.47, 0.015), yellow)
	for side in [-1.0, 1.0]:
		Kit.beam(rider, Vector3(side * 0.17, 1.12, 0.32), Vector3(side * 0.31, 0.86, -0.02), 0.105, black)
		Kit.beam(rider, Vector3(side * 0.31, 0.86, -0.02), Vector3(side * 0.25, 0.61, 0.24), 0.075, black)
		Kit.box(rider, Vector3(0.15, 0.12, 0.28), Vector3(side * 0.25, 0.61, 0.14), sole)
		Kit.beam(rider, Vector3(side * 0.23, 1.61, 0.12), Vector3(side * 0.32, 1.33, -0.09), 0.085, black)
		Kit.beam(rider, Vector3(side * 0.32, 1.33, -0.09), Vector3(side * 0.39, 1.21, -0.5), 0.067, black)
		Kit.sphere(rider, Vector3(0.14, 0.14, 0.17), Vector3(side * 0.39, 1.21, -0.5), black)
		Kit.sphere(rider, Vector3(0.09, 0.19, 0.13), Vector3(side * 0.26, 1.58, 0.1), yellow)
	# Actual 3D stylized identity study; replace with a skinned production mesh later.
	Kit.sphere(rider, Vector3(0.43, 0.47, 0.37), Vector3(0, 1.91, 0.025), hair)
	Kit.sphere(rider, Vector3(0.35, 0.35, 0.31), Vector3(0, 1.89, -0.1), skin)
	Kit.sphere(rider, Vector3(0.25, 0.17, 0.12), Vector3(0, 1.8, -0.25), skin)
	for side in [-1.0, 1.0]:
		Kit.sphere(rider, Vector3(0.19, 0.24, 0.1), Vector3(side * 0.25, 1.92, 0), skin)
		Kit.sphere(rider, Vector3(0.1, 0.08, 0.025), Vector3(side * 0.09, 1.96, -0.255), Kit.material(Color("f0e1b0")))
		Kit.sphere(rider, Vector3(0.035, 0.045, 0.025), Vector3(side * 0.09, 1.95, -0.274), black)
	for tuft in 7:
		var spike := Kit.cylinder(rider, 0.09, 0.27, Vector3((tuft - 3) * 0.053, 2.14 + sin(tuft) * 0.04, 0.02), hair, 0.0)
		spike.rotation.z = (3 - tuft) * 0.16
		spike.rotation.x = -0.25


func animate_motion(speed: float, steer: float, delta: float) -> void:
	for wheel in wheels:
		wheel.rotate_x(-speed * delta / 0.36)
	steering.rotation.y = -steer * 0.25
