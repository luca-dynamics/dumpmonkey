class_name RaceSession
extends RefCounted

enum State { MENU, COUNTDOWN, RIDING, FINISHED }
var state: State = State.MENU
var race: bool = false
var elapsed: float = 0.0
var countdown: float = 3.0
var checkpoint: int = 0
var invalid: bool = false
var wheelie_distance: float = 0.0
var wheelie_time: float = 0.0
var best_wheelie: float = 0.0
var _last_distance: float = 0.0


func begin(is_race: bool) -> void:
	race = is_race
	state = State.COUNTDOWN if race else State.RIDING
	elapsed = 0
	countdown = 3
	checkpoint = 0
	invalid = false
	wheelie_distance = 0
	wheelie_time = 0
	_last_distance = 0


func tick(delta: float, pitch: float, speed: float, rear_contact: bool, distance: float) -> void:
	if state == State.COUNTDOWN:
		countdown -= delta
		if countdown <= 0:
			state = State.RIDING
		return
	if state != State.RIDING:
		return
	elapsed += delta
	if pitch > 0.24 and speed >= 5.5 and rear_contact:
		wheelie_time += delta
		wheelie_distance += maxf(0, distance - _last_distance)
		best_wheelie = maxf(best_wheelie, wheelie_distance)
	else:
		wheelie_time = 0
		wheelie_distance = 0
	_last_distance = distance


func cross_checkpoint(index: int) -> bool:
	if not race or state != State.RIDING or index != checkpoint:
		return false
	checkpoint += 1
	if checkpoint == 4:
		state = State.FINISHED
	return true


func invalidate() -> void:
	invalid = true
	wheelie_distance = 0
	wheelie_time = 0


static func time_text(value: float) -> String:
	var minutes := int(value) / 60
	return "%02d:%05.2f" % [minutes, fmod(value, 60.0)]
