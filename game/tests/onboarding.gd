extends SceneTree

const Lesson = preload("res://modes/ride_lesson.gd")
const Save = preload("res://core/save_service.gd")
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
	var lesson := Lesson.new()
	lesson.begin(0)
	lesson.tick(1, {"throttle": 1}, 8, 0, false, 0)
	check(lesson.step == Lesson.Step.ACCELERATE, "airborne speed cannot complete throttle lesson")
	lesson.tick(0.7, {"throttle": 1}, 5, 0, true, 0)
	check(lesson.step == Lesson.Step.BRAKE, "sustained grounded throttle completes first skill")
	lesson.tick(1, {}, 0, 0, true, 0)
	check(lesson.step == Lesson.Step.BRAKE, "coasting to rest does not substitute for braking input")
	lesson.tick(0.3, {"brake": 1}, 0, 0, true, 0)
	check(lesson.step == Lesson.Step.STEER, "braking to a stop completes second skill")
	lesson.tick(1, {"steer": 1}, 0, 0, true, 0.5)
	check(lesson.step == Lesson.Step.STEER, "stationary steering cannot complete turning skill")
	lesson.tick(0.5, {"steer": 1}, 5, 0, true, 0.8)
	check(lesson.step == Lesson.Step.WHEELIE, "actual heading change while rolling completes turning skill")
	lesson.tick(1, {"wheelie": 1}, 8, 0.6, true, 0.8)
	lesson.tick(0.1, {"wheelie": 1}, 8, 0.6, false, 0.8)
	check(lesson.progress == 0, "loss of rear contact resets continuous wheelie hold")
	lesson.recover(0)
	check(lesson.step == Lesson.Step.WHEELIE and lesson.progress == 0, "retry retains completed lessons")
	lesson.tick(1.3, {"wheelie": 1}, 8, 0.6, true, 0)
	check(lesson.step == Lesson.Step.LAND, "balanced hold unlocks landing skill")
	lesson.tick(1, {}, 0, 0, true, 0)
	check(lesson.step == Lesson.Step.LAND, "stopping does not count as a rolling landing")
	lesson.tick(0.4, {}, 5, 0, true, 0)
	check(lesson.step == Lesson.Step.COMPLETE, "controlled rolling landing completes introduction")
	await _test_scene()
	print("ONBOARDING RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func _test_scene() -> void:
	var packed: PackedScene = load("res://crew_yard.tscn")
	var world: Node3D = packed.instantiate()
	world.profile.path = "user://onboarding_test_profile.json"
	root.add_child(world)
	current_scene = world
	check(world.hud.root.get_node("TitleArtwork").texture != null, "generated onboarding background loads into title screen")
	world.profile.introduction_complete = false
	world._apply_browser_motion_preference(0)
	check(not world.profile.reduced_motion, "numeric false from browser bridge initializes motion preference")
	world._apply_browser_motion_preference(1)
	check(world.profile.reduced_motion, "numeric true from browser bridge initializes motion preference")
	world._apply_browser_motion_preference(false)
	check(not world.profile.reduced_motion, "boolean browser preference remains supported")
	world.profile.reduced_motion = false
	world._update_profile_ui()
	world.hud.journey_requested.emit()
	check(world.camera.arrival_active and not world.bike.active, "start riding begins locked cinematic")
	world._pause(true)
	var skip: Button = world.hud.arrival.find_children("*", "Button", true, false)[0]
	check(skip.disabled, "pause disables underlying cinematic controls")
	var before: float = world.camera.arrival_time
	for frame in 5:
		await process_frame
	check(world.camera.arrival_time == before, "cinematic pauses when interrupted")
	world._pause(false)
	check(not skip.disabled, "resume restores cinematic controls")
	world.hud.skip_arrival_requested.emit()
	check(world.opening == world.Opening.LESSON and world.bike.active, "skip arrival enters interactive lesson immediately")
	check(world.hud.lesson_panel.visible and not world.hud.tips_panel.visible, "lesson shows one prompt instead of a controls dump")
	world.hud.skip_lesson_requested.emit()
	check(not world.profile.introduction_complete, "skipping lesson never marks it completed")
	check(world.hud.invitation_panel.visible and not world.bike.active, "skip offers challenge choice and stops bike")
	world._menu()
	world.profile.reduced_motion = true
	world._begin_journey()
	check(not world.camera.arrival_active and world.opening == world.Opening.LESSON, "reduced motion bypasses camera sequence")
	# Drive all five lessons with real controller commands; no teleports or synthetic telemetry.
	for expected in 5:
		var budget := 360
		while int(world.lesson.step) == expected and budget > 0:
			match expected:
				0: world.bike.command_override = {"throttle": 1.0}
				1: world.bike.command_override = {"brake": 1.0}
				2: world.bike.command_override = {"throttle": 1.0, "steer": 0.45}
				3: world.bike.command_override = {"throttle": 1.0, "wheelie": 1.0}
				4: world.bike.command_override = {"throttle": 0.5}
			await physics_frame
			budget -= 1
		check(int(world.lesson.step) > expected, "physics input completes lesson %d" % (expected + 1))
		if budget == 0:
			break
	check(world.profile.introduction_complete and world.hud.invitation_panel.visible, "five learned skills persist completion and offer challenge")
	var loaded := Save.new()
	loaded.path = world.profile.path
	loaded.load_profile()
	check(loaded.introduction_complete and loaded.reduced_motion, "completion and motion preference survive save readback")
	world._menu()
	world._begin_journey()
	check(world.opening == world.Opening.NONE and world.bike.active, "returning player continues without repeating lesson")
	world._menu()
	world._begin_journey(true)
	check(world.opening == world.Opening.LESSON, "completed player can replay introduction")
	world._menu()
	check(not world.camera.arrival_active and not world.hud.lesson_panel.visible, "cancel restores title without stale camera or coaching")
	world.profile.reduced_motion = false
	world._begin_journey(true)
	world.camera.arrival_time = world.camera.ARRIVAL_DURATION - 0.01
	world.camera._process(0.02)
	check(world.opening == world.Opening.LESSON, "arrival completion hands off automatically to riding")
	world._menu()
	world.queue_free()
	await process_frame
