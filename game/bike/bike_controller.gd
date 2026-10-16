class_name CrewBike
extends CharacterBody3D

signal wiped_out

const Tuning = preload("res://data/bike_tuning.gd")
var tuning: BikeTuning = Tuning.new()
var speed: float = 0.0
var pitch: float = 0.0
var pitch_velocity: float = 0.0
var steer: float = 0.0
var distance: float = 0.0
var active: bool = false
var crashed: bool = false
var rear_contact: bool = false
var visual: Node3D
var ground_probe: RayCast3D
var command_override: Dictionary = {}
var spawn_transform: Transform3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	floor_snap_length = 0.45
	floor_max_angle = deg_to_rad(48.0)
	ground_probe = RayCast3D.new()
	ground_probe.position = Vector3(0.0, 0.65, 0.67)
	ground_probe.target_position = Vector3(0.0, -1.0, 0.0)
	ground_probe.exclude_parent = true
	add_child(ground_probe)
	spawn_transform = global_transform


func read_command() -> Dictionary:
	if not command_override.is_empty():
		return command_override
	return {
		"throttle": Input.get_action_strength("throttle"),
		"brake": Input.get_action_strength("brake"),
		"steer": Input.get_axis("left", "right"),
		"wheelie": Input.get_action_strength("wheelie"),
		"balance": Input.get_axis("balance_down", "balance_up")
	}


func reset_to(at: Transform3D) -> void:
	global_transform = at
	velocity = Vector3.ZERO
	speed = 0.0
	pitch = 0.0
	pitch_velocity = 0.0
	steer = 0.0
	crashed = false
	ground_probe.force_raycast_update()
	if visual:
		visual.rotation = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if not active or crashed:
		return
	var command := read_command()
	var throttle: float = float(command.get("throttle", 0.0))
	var brake: float = float(command.get("brake", 0.0))
	steer = move_toward(steer, float(command.get("steer", 0.0)), delta * 5.0)
	var grounded := is_on_floor()
	rear_contact = ground_probe.is_colliding() and grounded
	var acceleration := throttle * tuning.acceleration - brake * tuning.braking
	if throttle < 0.1:
		acceleration -= tuning.drag
	speed = clampf(speed + acceleration * delta, 0.0, tuning.top_speed)
	var speed_ratio := speed / tuning.top_speed
	var steering_power := tuning.turn_rate * lerpf(1.0, 0.44, speed_ratio)
	rotate_y(-steer * steering_power * minf(speed / 5.0, 1.0) * delta)
	var forward := -global_basis.z
	var target := forward * speed
	velocity.x = move_toward(velocity.x, target.x, tuning.grip * delta * maxf(speed, 3.0))
	velocity.z = move_toward(velocity.z, target.z, tuning.grip * delta * maxf(speed, 3.0))
	if grounded:
		velocity.y = -0.5
	else:
		velocity.y -= tuning.gravity * delta
	_update_wheelie(command, delta)
	var before := global_position
	move_and_slide()
	distance += Vector2(global_position.x - before.x, global_position.z - before.z).length()
	for index in get_slide_collision_count():
		var hit := get_slide_collision(index)
		if absf(hit.get_normal().y) < 0.4 and speed > 2.0:
			speed *= 0.25
			if before.distance_to(global_position) < speed * delta * 0.2:
				velocity.x = 0.0
				velocity.z = 0.0
	if global_position.y < -8.0:
		_crash()
	if visual:
		var slope_pitch := 0.0
		if is_on_floor():
			var local_normal := global_basis.inverse() * get_floor_normal()
			slope_pitch = atan2(local_normal.z, local_normal.y)
		visual.rotation.x = pitch + slope_pitch
		visual.rotation.z = lerpf(visual.rotation.z, -steer * speed_ratio * 0.38, 1.0 - exp(-8.0 * delta))
		var rear_pivot := Vector3(0, 0.37, 0.78)
		visual.position = rear_pivot - visual.basis * rear_pivot
		visual.position.y += sin(distance * 5.0) * speed_ratio * 0.008


func _update_wheelie(command: Dictionary, delta: float) -> void:
	var lifting := float(command.get("wheelie", 0.0)) > 0.1
	var brake := float(command.get("brake", 0.0))
	var balance := float(command.get("balance", 0.0))
	if rear_contact and speed >= tuning.wheelie_min_speed and lifting:
		# Easy entry, then a balance point that needs small player corrections.
		var target_pitch := 0.64
		var acceleration := (target_pitch - pitch) * 7.5 - pitch_velocity * 3.5
		if pitch > 0.48:
			acceleration += sin(distance * 0.45) * 0.48 + 0.32
		acceleration += balance * 3.4 - brake * 5.0
		pitch_velocity += acceleration * delta
		pitch += pitch_velocity * delta
	else:
		pitch_velocity = move_toward(pitch_velocity, -1.4 - brake * 1.5, delta * 4.0)
		pitch += pitch_velocity * delta
	if pitch <= 0.0:
		pitch = 0.0
		pitch_velocity = 0.0
	if pitch > tuning.wheelie_fail_angle:
		_crash()


func _crash() -> void:
	if crashed:
		return
	crashed = true
	speed = 0.0
	wiped_out.emit()
