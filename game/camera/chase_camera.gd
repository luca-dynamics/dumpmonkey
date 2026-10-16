extends Camera3D

signal arrival_finished
const ARRIVAL_DURATION: float = 7.0
var target: CharacterBody3D
var initialized: bool = false
var arrival_active: bool = false
var arrival_paused: bool = false
var arrival_time: float = 0.0
var reduced_motion: bool = false


func begin_arrival() -> void:
	arrival_active = true
	arrival_paused = false
	arrival_time = 0
	_sample_arrival()


func end_arrival() -> void:
	arrival_active = false
	arrival_paused = false
	initialized = false


func _sample_arrival() -> void:
	var origin := target.global_position
	var t := arrival_time
	var focus := origin + Vector3.UP * 1.1
	if t < 2.5:
		global_position = origin + Vector3(5.5, 2.3, 4.5).lerp(Vector3(3.3, 1.8, 2.7), smoothstep(0, 2.5, t))
		fov = 48
	elif t < 4.5:
		global_position = origin + Vector3(1.8, 1.1, -1.6).lerp(Vector3(2.2, 1.4, -1.1), smoothstep(2.5, 4.5, t))
		focus = origin + Vector3(0, 1.15, -0.1)
		fov = 48
	else:
		global_position = origin + Vector3(-2.8, 1.9, 3.6).lerp(Vector3(0, 2.65, 5.4), smoothstep(4.5, ARRIVAL_DURATION, t))
		focus = origin + Vector3(0, 1.1, 0).lerp(Vector3(0, 1.25, -1.8), smoothstep(4.5, ARRIVAL_DURATION, t))
		fov = lerpf(48, 65, smoothstep(4.5, ARRIVAL_DURATION, t))
	look_at(focus)


func _process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	if arrival_active:
		if not arrival_paused:
			arrival_time = minf(arrival_time + delta, ARRIVAL_DURATION)
		_sample_arrival()
		if arrival_time >= ARRIVAL_DURATION:
			end_arrival()
			arrival_finished.emit()
		return
	var speed: float = target.speed
	var desired := target.global_position + target.global_basis.z * (5.4 + speed * 0.025) + Vector3.UP * 2.65
	var focus := target.global_position + Vector3.UP * 1.25 - target.global_basis.z * 1.8
	# Sweep the camera boom against the environment instead of clipping through it.
	var query := PhysicsRayQueryParameters3D.create(focus, desired)
	query.exclude = [target.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		desired = hit.position + hit.normal * 0.35
	if not initialized or global_position.distance_to(desired) > 25.0:
		global_position = desired
		initialized = true
	else:
		global_position = global_position.lerp(desired, 1.0 - exp(-7.0 * delta))
	look_at(focus)
	fov = lerpf(fov, 65.0 + (0.0 if reduced_motion else speed * 0.28), 1.0 - exp(-3.0 * delta))
