extends RefCounted

const PATH := "user://crew_yard_v1.json"
var path: String = PATH
var best_time: float = 0
var best_wheelie: float = 0
var muted: bool = false
var introduction_complete: bool = false
var reduced_motion: bool = false
var has_motion_preference: bool = false
var available: bool = true


func load_profile() -> void:
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		available = false
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	if not data is Dictionary or data.get("version") != 1:
		return
	# Local records are convenience data, never an authoritative reward ledger.
	best_time = _valid_number(data.get("best_time", 0))
	best_wheelie = _valid_number(data.get("best_wheelie", 0))
	muted = data.get("muted", false) == true
	introduction_complete = data.get("introduction_complete", false) == true
	has_motion_preference = data.has("reduced_motion")
	reduced_motion = data.get("reduced_motion", false) == true


func save_profile() -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		available = false
		return
	file.store_string(JSON.stringify({"version": 1, "best_time": best_time, "best_wheelie": best_wheelie, "muted": muted, "introduction_complete": introduction_complete, "reduced_motion": reduced_motion}))
	file.flush()
	available = file.get_error() == OK


func _valid_number(value: Variant) -> float:
	if (value is int or value is float) and is_finite(float(value)):
		return maxf(0, float(value))
	return 0
