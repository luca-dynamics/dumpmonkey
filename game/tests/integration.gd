extends SceneTree

const Session = preload("res://modes/race_session.gd")
const Track = preload("res://tracks/crew_yard.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		push_error(message)


func _run() -> void:
	var packed: PackedScene = load("res://crew_yard.tscn")
	var world: Node3D = packed.instantiate()
	world.profile.path = "user://crew_yard_integration_test.json"
	root.add_child(world)
	current_scene = world
	await process_frame
	check(world.hud.menu.visible and not world.bike.active, "title screen prevents movement")
	world.hud.garage_requested.emit()
	check(world.hud.garage.visible and not world.hud.menu.visible, "garage opens from title without starting the bike")
	check(world.hud.garage_section_title.text == "BIKE TUNING", "garage opens on the bike tuning section")
	world._menu()
	world.hud.start_requested.emit(true)
	check(world.session.state == Session.State.COUNTDOWN and not world.bike.active, "time-trial button starts countdown")
	world._pause(true)
	var time_before: float = world.session.countdown
	for frame in 12:
		await physics_frame
	check(is_equal_approx(time_before, world.session.countdown), "pause freezes countdown")
	world._pause(false)
	for frame in 190:
		await physics_frame
	check(world.session.state == Session.State.RIDING and world.bike.active, "countdown enables controller")
	# Exercise actual sweep/order/finish integration, independent of driving skill.
	for gate in 4:
		var direction: Vector3 = Track.DIRECTIONS[gate]
		world.previous_position = Track.GATES[gate] - direction
		world.bike.global_position = Track.GATES[gate] + direction
		world._check_gate()
	check(world.session.state == Session.State.FINISHED, "all directional gates finish the run")
	world._finish()
	check(world.hud.result_panel.visible and not world.bike.active, "finish shows results and stops controller")
	world._start(true)
	world.session.state = Session.State.RIDING
	world.bike.active = true
	world._respawn()
	check(world.session.invalid, "in-race respawn marks result unranked")
	world._start(false)
	world.bike.command_override = {"throttle": 1.0}
	for frame in 50:
		await physics_frame
	check(world.bike.speed > 5, "free-ride button enables driving")
	world._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var elapsed: float = world.session.elapsed
	var position: Vector3 = world.bike.global_position
	for frame in 12:
		await physics_frame
	check(world.paused and world.hud.pause_panel.visible, "focus loss opens pause")
	check(is_equal_approx(elapsed, world.session.elapsed) and world.bike.global_position.is_equal_approx(position), "focus loss freezes timer and movement")
	world._menu()
	check(world.hud.menu.visible and world.session.state == Session.State.MENU, "return-to-yard restores menu")
	world.queue_free()
	await process_frame
	print("INTEGRATION RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
