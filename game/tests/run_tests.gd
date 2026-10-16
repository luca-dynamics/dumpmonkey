extends SceneTree

const Session = preload("res://modes/race_session.gd")
const World = preload("res://core/crew_yard.gd")
const Bike = preload("res://bike/bike_controller.gd")
const Kit = preload("res://core/mesh_kit.gd")
var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)
	else:
		print("PASS: ", description)


func _run() -> void:
	var race := Session.new()
	race.begin(true)
	check(not race.cross_checkpoint(0), "countdown cannot award checkpoints")
	race.tick(3.1, 0, 0, true, 0)
	check(race.state == Session.State.RIDING, "countdown unlocks riding")
	check(not race.cross_checkpoint(2), "out-of-order gate rejected")
	for gate in 4:
		check(race.cross_checkpoint(gate), "ordered gate %d accepted" % gate)
	check(race.state == Session.State.FINISHED, "four gates finish a trial")
	check(not race.cross_checkpoint(0), "finished run rejects duplicate gates")
	race.begin(false)
	race.tick(0.5, 0.6, 20, false, 10)
	check(race.wheelie_distance == 0, "airborne wheelie does not score")
	race.tick(0.5, 0.6, 0, true, 10)
	check(race.wheelie_distance == 0, "stationary wheelie does not score")
	race.tick(0.5, 0.6, 20, true, 20)
	check(is_equal_approx(race.wheelie_distance, 10), "valid rear-grounded wheelie scores distance")
	race.invalidate()
	check(race.invalid and race.wheelie_distance == 0, "reset invalidates run and ends stunt")
	check(World.gate_crossed(Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3.ZERO, Vector3.FORWARD), "forward swept gate crossing accepted")
	check(not World.gate_crossed(Vector3(0, 0, -1), Vector3(0, 0, 1), Vector3.ZERO, Vector3.FORWARD), "reverse gate crossing rejected")
	check(not World.gate_crossed(Vector3(9, 0, 1), Vector3(9, 0, -1), Vector3.ZERO, Vector3.FORWARD), "crossing outside gate rejected")
	check(not World.gate_crossed(Vector3(0, 8, 1), Vector3(0, 8, -1), Vector3.ZERO, Vector3.FORWARD), "flying over gate rejected")
	await _test_physics()
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func _test_physics() -> void:
	var scene := Node3D.new()
	root.add_child(scene)
	Kit.box(scene, Vector3(200, 1, 240), Vector3(0, -0.5, 0), Kit.material(Color.GRAY), true)
	Kit.box(scene, Vector3(30, 5, 0.25), Vector3(0, 2.5, -80), Kit.material(Color.GRAY), true)
	var bike := Bike.new()
	scene.add_child(bike)
	bike.active = true
	bike.command_override = {"throttle": 1.0}
	for frame in 150:
		await physics_frame
	check(bike.speed > 25 and bike.global_position.z < -20, "physics: throttle accelerates and moves bike")
	check(bike.is_on_floor(), "physics: bike maintains floor contact")
	bike.command_override = {"throttle": 0.0, "brake": 1.0}
	for frame in 90:
		await physics_frame
	check(bike.speed < 0.1, "physics: braking brings bike to rest")
	bike.reset_to(Transform3D(Basis.IDENTITY, Vector3.ZERO))
	bike.command_override = {"throttle": 1.0, "wheelie": 1.0}
	for frame in 100:
		await physics_frame
	check(bike.pitch > 0.4 and bike.rear_contact and not bike.crashed, "physics: assisted wheelie reaches controllable pitch")
	bike.command_override = {"throttle": 1.0, "wheelie": 1.0, "balance": 1.0}
	for frame in 100:
		await physics_frame
	check(bike.crashed, "physics: excessive balance input triggers wipeout")
	bike.reset_to(Transform3D(Basis.IDENTITY, Vector3(0, 0, -72)))
	bike.speed = bike.tuning.top_speed
	bike.command_override = {"throttle": 1.0}
	for frame in 60:
		await physics_frame
	check(bike.global_position.z > -80, "physics: top-speed sweep does not tunnel through thin wall")
	check(not bike.crashed and bike.pitch == 0, "physics: reset clears crash and wheelie state")
	scene.queue_free()
	await process_frame
