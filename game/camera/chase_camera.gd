extends Camera3D

var target: CharacterBody3D
var initialized: bool = false


func _process(delta: float) -> void:
	if not is_instance_valid(target):
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
	fov = lerpf(fov, 65.0 + speed * 0.28, 1.0 - exp(-3.0 * delta))
