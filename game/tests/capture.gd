extends SceneTree

func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var packed: PackedScene = load("res://crew_yard.tscn")
	var scene: Node3D = packed.instantiate()
	scene.profile.path = "user://crew_yard_visual_test.json"
	root.add_child(scene)
	current_scene = scene
	scene.profile.introduction_complete = false
	scene._update_profile_ui()
	if "--capture-ride" in OS.get_cmdline_user_args():
		scene._start(false)
	if "--capture-arrival" in OS.get_cmdline_user_args():
		scene.profile.introduction_complete = false
		scene.profile.reduced_motion = false
		scene._begin_journey(true)
	if "--capture-lesson" in OS.get_cmdline_user_args():
		scene._start_tutorial()
	if "--capture-invitation" in OS.get_cmdline_user_args():
		scene._start_tutorial()
		scene._complete_lesson(true)
	for frame in 45:
		await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var filename := "ride.png" if "--capture-ride" in OS.get_cmdline_user_args() else "title.png"
	for name in ["arrival", "lesson", "invitation"]:
		if "--capture-" + name in OS.get_cmdline_user_args():
			filename = name + ".png"
	var error := root.get_texture().get_image().save_png("res://test-output/" + filename)
	print("CAPTURE ", filename, ": ", error)
	quit(error)
