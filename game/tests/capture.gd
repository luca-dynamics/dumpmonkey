extends SceneTree

func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var packed: PackedScene = load("res://crew_yard.tscn")
	var scene: Node3D = packed.instantiate()
	root.add_child(scene)
	current_scene = scene
	if "--capture-ride" in OS.get_cmdline_user_args():
		scene._start(false)
	for frame in 45:
		await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://test-output")
	var filename := "ride.png" if "--capture-ride" in OS.get_cmdline_user_args() else "title.png"
	var error := root.get_texture().get_image().save_png("res://test-output/" + filename)
	print("CAPTURE ", filename, ": ", error)
	quit(error)
