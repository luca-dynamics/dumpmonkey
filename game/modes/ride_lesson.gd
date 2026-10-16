class_name RideLesson
extends RefCounted

enum Step { ACCELERATE, BRAKE, STEER, WHEELIE, LAND, COMPLETE }
var step: Step = Step.ACCELERATE
var progress: float = 0.0
var elapsed: float = 0.0
var _hold: float = 0.0
var _turn: float = 0.0
var _previous_heading: float = 0.0


func begin(heading: float) -> void:
	step = Step.ACCELERATE
	recover(heading)


func recover(heading: float) -> void:
	# Reset the current attempt, never erase already learned skills.
	progress = 0.0
	elapsed = 0.0
	_hold = 0.0
	_turn = 0.0
	_previous_heading = heading


func tick(delta: float, command: Dictionary, speed: float, pitch: float, rear_contact: bool, heading: float) -> bool:
	if step == Step.COMPLETE:
		return false
	elapsed += delta
	var turn_delta := absf(wrapf(heading - _previous_heading, -PI, PI))
	_previous_heading = heading
	var valid := false
	var duration := 0.6
	match step:
		Step.ACCELERATE:
			valid = speed >= 4.2 and float(command.get("throttle", 0)) > 0.2 and rear_contact
		Step.BRAKE:
			valid = speed < 1.0 and float(command.get("brake", 0)) > 0.2 and rear_contact
			duration = 0.2
		Step.STEER:
			if speed >= 2.5 and rear_contact and absf(float(command.get("steer", 0))) > 0.25:
				_turn += turn_delta
			progress = minf(_turn / 0.24, 1.0)
			if progress >= 1:
				_advance()
				return true
			return false
		Step.WHEELIE:
			valid = rear_contact and speed >= 5.5 and pitch >= 0.3 and pitch < 0.95 and float(command.get("wheelie", 0)) > 0.1
			duration = 1.2
		Step.LAND:
			valid = rear_contact and speed > 1 and pitch < 0.1 and float(command.get("wheelie", 0)) < 0.1
			duration = 0.3
	_hold = _hold + delta if valid else 0.0
	progress = clampf(_hold / duration, 0, 1)
	if progress >= 1:
		_advance()
		return true
	return false


func _advance() -> void:
	step = (int(step) + 1) as Step
	recover(_previous_heading)
