extends Node3D

const Bike = preload("res://bike/bike_controller.gd")
const Visual = preload("res://bike/bike_visual.gd")
const Track = preload("res://tracks/crew_yard.gd")
const Camera = preload("res://camera/chase_camera.gd")
const Hud = preload("res://ui/racing_hud.gd")
const Session = preload("res://modes/race_session.gd")
const Save = preload("res://core/save_service.gd")
const Lesson = preload("res://modes/ride_lesson.gd")
const Feedback = preload("res://core/feedback_audio.gd")
enum Opening { NONE, ARRIVAL, LESSON, INVITATION }
var opening: Opening = Opening.NONE
var lesson: RideLesson = Lesson.new()
var feedback: Node
var normal_top_speed: float = 38.0
var bike: CharacterBody3D
var track: Node3D
var camera: Camera3D
var hud: CanvasLayer
var session: RaceSession = Session.new()
var profile = Save.new()
var paused: bool = false
var toast_time: float = 0.0
var previous_position := Vector3.ZERO
var spawn := Transform3D(Basis.IDENTITY, Vector3(-24, 0.15, 39))
var engine: AudioStreamPlayer
var _engine_started: bool = false


func _ready() -> void:
	_bind_inputs()
	profile.load_profile()
	if OS.has_feature("web") and not profile.has_motion_preference:
		_apply_browser_motion_preference(JavaScriptBridge.eval("window.matchMedia('(prefers-reduced-motion: reduce)').matches"))
	_setup_environment()
	track = Track.new()
	add_child(track)
	bike = Bike.new()
	bike.transform = spawn
	add_child(bike)
	var visual := Visual.new()
	bike.add_child(visual)
	bike.visual = visual
	bike.wiped_out.connect(_on_crash)
	camera = Camera.new()
	camera.target = bike
	camera.current = true
	add_child(camera)
	camera.arrival_finished.connect(_finish_arrival)
	hud = Hud.new()
	add_child(hud)
	hud.start_requested.connect(_start)
	hud.journey_requested.connect(_begin_journey)
	hud.lesson_requested.connect(func(): _begin_journey(true))
	hud.skip_arrival_requested.connect(_finish_arrival)
	hud.skip_lesson_requested.connect(func(): _complete_lesson(false))
	hud.retry_requested.connect(_restart)
	hud.resume_requested.connect(func(): _pause(false))
	hud.menu_requested.connect(_menu)
	hud.mute_requested.connect(_toggle_sound)
	hud.motion_requested.connect(_toggle_motion)
	_setup_audio()
	feedback = Feedback.new()
	add_child(feedback)
	hud.ui_confirmed.connect(feedback.play_confirm)
	_update_profile_ui()
	hud.show_menu()
	track.highlight_gate(-1)
	# Explicit dev switches are useful for visual checks, never active by default.
	if "--practice" in OS.get_cmdline_user_args():
		_start(false)
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.dispatchEvent(new Event('dumpmonkey:ready'))")


func _apply_browser_motion_preference(value: Variant) -> void:
	# The bridge can represent JavaScript booleans as integer variants on web.
	profile.reduced_motion = bool(value)


func _setup_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("477a94")
	sky_mat.sky_horizon_color = Color("d9c5a0")
	sky_mat.ground_bottom_color = Color("29323b")
	sky_mat.ground_horizon_color = Color("b7ad8c")
	sky.sky_material = sky_mat
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b5c9db")
	environment.ambient_light_energy = 0.4
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-36, -32, 0)
	sun.light_color = Color("ffe2a8")
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 100
	add_child(sun)


func _bind_inputs() -> void:
	var actions := {
		"throttle": [KEY_W, KEY_UP], "brake": [KEY_S, KEY_DOWN],
		"left": [KEY_A, KEY_LEFT], "right": [KEY_D, KEY_RIGHT],
		"wheelie": [KEY_SPACE], "balance_down": [KEY_Q], "balance_up": [KEY_E],
		"respawn": [KEY_R], "pause": [KEY_ESCAPE], "mute": [KEY_M]
	}
	for action: String in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key: int in actions[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	for binding in [["throttle", JOY_AXIS_TRIGGER_RIGHT, 1.0], ["brake", JOY_AXIS_TRIGGER_LEFT, 1.0], ["left", JOY_AXIS_LEFT_X, -1.0], ["right", JOY_AXIS_LEFT_X, 1.0], ["balance_down", JOY_AXIS_RIGHT_Y, 1.0], ["balance_up", JOY_AXIS_RIGHT_Y, -1.0]]:
		var event := InputEventJoypadMotion.new()
		event.axis = binding[1]
		event.axis_value = binding[2]
		InputMap.action_add_event(binding[0], event)
	for binding in [["wheelie", JOY_BUTTON_A], ["pause", JOY_BUTTON_START], ["respawn", JOY_BUTTON_Y]]:
		var event := InputEventJoypadButton.new()
		event.button_index = binding[1]
		InputMap.action_add_event(binding[0], event)


func _start(is_race: bool) -> void:
	_commit_wheelie()
	opening = Opening.NONE
	camera.end_arrival()
	bike.tuning.top_speed = normal_top_speed
	paused = false
	bike.reset_to(spawn)
	bike.distance = 0
	previous_position = bike.global_position
	session.begin(is_race)
	bike.active = not is_race
	camera.initialized = false
	hud.start_run()
	hud.toast_label.text = "Follow the yellow gates" if is_race else "Your yard. Your rules."
	toast_time = 4
	track.highlight_gate(0 if is_race else -1)
	_ensure_audio()


func _ensure_audio() -> void:
	if not _engine_started:
		engine.play()
		_engine_started = true


func _begin_journey(replay: bool = false) -> void:
	if profile.introduction_complete and not replay:
		_start(false)
		return
	if profile.reduced_motion:
		_start_tutorial()
		return
	paused = false
	opening = Opening.ARRIVAL
	session.state = Session.State.MENU
	bike.reset_to(spawn)
	bike.active = false
	hud.show_arrival()
	camera.begin_arrival()
	_ensure_audio()


func _finish_arrival() -> void:
	if opening != Opening.ARRIVAL:
		return
	camera.end_arrival()
	_start_tutorial()


func _start_tutorial() -> void:
	_start(false)
	opening = Opening.LESSON
	bike.tuning.top_speed = 12.0
	lesson.begin(bike.rotation.y)
	hud.toast_label.text = ""
	toast_time = 0
	hud.show_lesson(lesson.step, lesson.progress)
	# The lesson's skip button is optional; gameplay keys must reach the controller.
	get_viewport().gui_release_focus()


func _tick_lesson(delta: float) -> void:
	if bike.crashed:
		return
	var advanced := lesson.tick(delta, bike.read_command(), bike.speed, bike.pitch, bike.rear_contact, bike.rotation.y)
	if advanced:
		feedback.play_success()
	if lesson.step == Lesson.Step.COMPLETE:
		_complete_lesson(true)
	else:
		hud.show_lesson(lesson.step, lesson.progress, lesson.elapsed)


func _complete_lesson(completed: bool) -> void:
	if opening != Opening.LESSON or paused:
		return
	_commit_wheelie()
	opening = Opening.INVITATION
	bike.active = false
	bike.tuning.top_speed = normal_top_speed
	session.state = Session.State.MENU
	if completed:
		profile.introduction_complete = true
		profile.save_profile()
	_update_profile_ui()
	hud.show_invitation(completed)


func _restart() -> void:
	if opening == Opening.ARRIVAL:
		_begin_journey(true)
	elif opening == Opening.LESSON:
		_start_tutorial()
	else:
		_start(session.race)


func _physics_process(delta: float) -> void:
	if paused:
		engine.volume_db = -80
		return
	if opening == Opening.ARRIVAL:
		engine.pitch_scale = 0.72
		engine.volume_db = -80 if profile.muted else -30
		hud.arrival_title.text = "CREW YARD" if camera.arrival_time < 2.5 else ("BUILT TO RIDE" if camera.arrival_time < 4.5 else "YOUR LINE STARTS HERE")
		var shutter := maxf(1 - absf(camera.arrival_time - 2.5) / 0.14, 1 - absf(camera.arrival_time - 4.5) / 0.14)
		hud.cinema_shutter.color.a = clampf(shutter, 0, 1)
		return
	if session.state == Session.State.MENU:
		engine.volume_db = -80
		return
	var previous_state := session.state
	session.tick(delta, bike.pitch, bike.speed, bike.rear_contact and not bike.crashed, bike.distance)
	if previous_state == Session.State.COUNTDOWN and session.state == Session.State.RIDING:
		bike.active = true
		hud.toast_label.text = "GO. FIND YOUR LINE."
		toast_time = 2
	if session.race and session.state == Session.State.RIDING:
		_check_gate()
	previous_position = bike.global_position
	if session.state == Session.State.FINISHED and previous_state != Session.State.FINISHED:
		_finish()
	if toast_time > 0:
		toast_time -= delta
		if toast_time <= 0:
			hud.toast_label.text = ""
	bike.visual.animate_motion(bike.speed if bike.active else 0.0, bike.steer, delta)
	_update_hud()
	if opening == Opening.LESSON and session.state == Session.State.RIDING:
		_tick_lesson(delta)
	engine.pitch_scale = lerpf(0.7, 2.5, bike.speed / bike.tuning.top_speed)
	engine.volume_db = -80 if profile.muted or bike.crashed or not bike.active else -24


func _check_gate() -> void:
	var index := session.checkpoint
	if index >= Track.GATES.size():
		return
	if gate_crossed(previous_position, bike.global_position, Track.GATES[index], Track.DIRECTIONS[index]):
		if session.cross_checkpoint(index):
			track.highlight_gate(session.checkpoint)
			hud.toast_label.text = "CHECKPOINT %d / 4" % session.checkpoint
			toast_time = 2


static func gate_crossed(before: Vector3, after: Vector3, center: Vector3, direction: Vector3) -> bool:
	var a := (before - center).dot(direction)
	var b := (after - center).dot(direction)
	if a >= 0 or b < 0 or is_equal_approx(a, b):
		return false
	var crossing := before.lerp(after, -a / (b - a)) - center
	var lateral := Vector3(-direction.z, 0, direction.x)
	return absf(crossing.dot(lateral)) <= 6.7 and crossing.y >= -0.3 and crossing.y < 3.5


func _finish() -> void:
	bike.active = false
	_commit_wheelie()
	var message := Session.time_text(session.elapsed)
	if session.invalid:
		message += "\nPractice result — respawn used"
	else:
		if profile.best_time == 0 or session.elapsed < profile.best_time:
			profile.best_time = session.elapsed
			message += "\nPERSONAL BEST"
		profile.save_profile()
	hud.show_result(message)
	_update_profile_ui()


func _update_hud() -> void:
	hud.speed_label.text = "%03d" % int(bike.speed * 3.6)
	hud.timer_label.text = Session.time_text(session.elapsed)
	hud.checkpoint_label.text = ("GATE %d / 4" % mini(session.checkpoint + 1, 4)) if session.race else "FREE RIDE"
	if session.invalid and session.race:
		hud.checkpoint_label.text += "  /  UNRANKED"
	hud.balance.value = bike.pitch
	hud.stunt_label.text = "%.1f M  /  %.1f S" % [session.wheelie_distance, session.wheelie_time] if session.wheelie_time > 0 else "LIFT IT. HOLD IT."
	hud.countdown_label.text = str(ceili(session.countdown)) if session.state == Session.State.COUNTDOWN else ""


func _on_crash() -> void:
	session.invalidate()
	hud.toast_label.text = "BALANCE LOST.  R TO RESPAWN."
	toast_time = 0


func _respawn() -> void:
	if session.state != Session.State.RIDING or paused:
		return
	_commit_wheelie()
	session.invalidate()
	bike.reset_to(spawn)
	previous_position = bike.global_position
	hud.toast_label.text = "BACK ON TWO WHEELS."
	toast_time = 3
	camera.initialized = false
	if opening == Opening.LESSON:
		lesson.recover(bike.rotation.y)
		hud.toast_label.text = "FRESH START. SAME LESSON."


func _unhandled_input(event: InputEvent) -> void:
	if opening == Opening.ARRIVAL and not paused and event.is_action_pressed("ui_accept") and not event.is_echo():
		_finish_arrival()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and not event.is_echo():
		if session.state in [Session.State.COUNTDOWN, Session.State.RIDING] or opening == Opening.ARRIVAL:
			_pause(not paused)
		elif opening == Opening.INVITATION:
			_menu()
	elif event.is_action_pressed("respawn") and not event.is_echo():
		_respawn()
	elif event.is_action_pressed("mute") and not event.is_echo():
		_toggle_sound()


func _pause(value: bool) -> void:
	paused = value
	camera.arrival_paused = value
	bike.active = not value and session.state == Session.State.RIDING and not bike.crashed
	hud.set_paused(value)
	if value:
		_commit_wheelie()
		for action in ["throttle", "brake", "left", "right", "wheelie", "balance_down", "balance_up"]:
			Input.action_release(action)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(hud):
		if session.state in [Session.State.COUNTDOWN, Session.State.RIDING] or opening == Opening.ARRIVAL:
			_pause(true)


func _menu() -> void:
	_commit_wheelie()
	opening = Opening.NONE
	camera.end_arrival()
	bike.tuning.top_speed = normal_top_speed
	paused = false
	bike.active = false
	session.state = Session.State.MENU
	hud.show_menu()
	_update_profile_ui()


func _commit_wheelie() -> void:
	profile.best_wheelie = maxf(profile.best_wheelie, session.best_wheelie)
	profile.save_profile()


func _toggle_sound() -> void:
	profile.muted = not profile.muted
	profile.save_profile()
	_update_profile_ui()


func _toggle_motion() -> void:
	profile.reduced_motion = not profile.reduced_motion
	profile.has_motion_preference = true
	profile.save_profile()
	_update_profile_ui()


func _input(event: InputEvent) -> void:
	if not is_instance_valid(hud):
		return
	if (event is InputEventJoypadButton and event.pressed) or (event is InputEventJoypadMotion and absf(event.axis_value) > 0.25):
		hud.gamepad_prompts = true
	elif event is InputEventKey:
		hud.gamepad_prompts = false


func _update_profile_ui() -> void:
	hud.mute_button.text = "SOUND OFF" if profile.muted else "SOUND ON"
	hud.primary_button.text = "CONTINUE RIDING    >" if profile.introduction_complete else "START RIDING    >"
	hud.motion_button.text = "REDUCED MOTION ON" if profile.reduced_motion else "REDUCED MOTION OFF"
	hud.reduced_motion = profile.reduced_motion
	camera.reduced_motion = profile.reduced_motion
	feedback.muted = profile.muted
	var best := Session.time_text(profile.best_time) if profile.best_time > 0 else "SET YOUR FIRST TIME"
	hud.best_label.text = "BEST  %s\nWHEELIE  %.1f M" % [best, profile.best_wheelie]
	if not profile.available:
		hud.best_label.text += "\nStorage unavailable — session only"


func _setup_audio() -> void:
	# Precomputed PCM sample, not AudioStreamGenerator (unsupported by web sample playback).
	var samples := PackedByteArray()
	var sample_rate := 22050
	samples.resize(sample_rate * 2)
	for index in sample_rate:
		var t := float(index) / sample_rate
		var value := sin(TAU * 70 * t) * 0.48 + sin(TAU * 140 * t) * 0.25 + sin(TAU * 210 * t) * 0.12
		samples.encode_s16(index * 2, int(value * 16000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.data = samples
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = sample_rate
	engine = AudioStreamPlayer.new()
	engine.stream = stream
	engine.volume_db = -80
	add_child(engine)
