extends Node

var muted: bool = false
var player: AudioStreamPlayer
var confirm: AudioStreamWAV
var success: AudioStreamWAV


func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.volume_db = -21
	add_child(player)
	confirm = _sample(false)
	success = _sample(true)


func play_success() -> void:
	_play(success)


func play_confirm() -> void:
	_play(confirm)


func _play(sample: AudioStreamWAV) -> void:
	if muted:
		return
	player.stream = sample
	player.play()


func _sample(celebrate: bool) -> AudioStreamWAV:
	var rate := 22050
	var duration := 0.36 if celebrate else 0.065
	var frames := int(rate * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	for frame in frames:
		var t := float(frame) / rate
		var frequency := 660.0 if not celebrate else (523.25 if t < 0.12 else 783.99)
		var envelope := minf(t * 150, 1.0) * pow(1 - t / duration, 2)
		var sample := (sin(TAU * frequency * t) + sin(TAU * frequency * 2 * t) * 0.15) * envelope
		data.encode_s16(frame * 2, int(sample * 19000))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav
