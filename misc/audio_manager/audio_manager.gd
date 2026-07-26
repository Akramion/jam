extends Node

@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var rewind_player: AudioStreamPlayer2D = $RewindPlayer
@onready var restart_player: AudioStreamPlayer2D = $RestartPlayer
@onready var level_complete_player: AudioStreamPlayer2D = $LevelCompletePlayer

@export_group("Music Volume")
@export var normal_music_volume_db := -6.0
@export var ducked_music_volume_db := -18.0
@export var menu_music_volume_db := -10.0

@export_group("Transitions")
@export var duck_duration := 0.12
@export var restore_duration := 0.5
@export var menu_transition_duration := 0.5

@export_group("Menu Filter")
@export var menu_cutoff_hz := 1100.0
@export var gameplay_cutoff_hz := 20000.0

const MUSIC_BUS_NAME := "Music"
const MUSIC_LOW_PASS_INDEX := 0

var music_bus_index := -1
var volume_tween: Tween
var filter_tween: Tween
var duck_requests := 0
var menu_mode := false


func _ready() -> void:
	music_bus_index = AudioServer.get_bus_index(MUSIC_BUS_NAME)

	if music_bus_index == -1:
		push_error("Audio bus '%s' not found" % MUSIC_BUS_NAME)
		return

	AudioServer.set_bus_volume_db(
		music_bus_index,
		normal_music_volume_db
	)

	play_music()


func play_music() -> void:
	if not music_player.playing:
		music_player.play()


func play_rewind() -> void:
	_play_level_sound_with_duck(rewind_player)


func play_restart() -> void:
	_play_level_sound_with_duck(restart_player)


func play_level_complete() -> void:
	_play_level_sound_with_duck(level_complete_player)


func _play_level_sound_with_duck(player: AudioStreamPlayer2D) -> void:
	duck_music()
	player.play()

	await player.finished

	restore_music()


func duck_music() -> void:
	duck_requests += 1

	_tween_music_volume(
		ducked_music_volume_db,
		duck_duration
	)


func restore_music() -> void:
	duck_requests = max(duck_requests - 1, 0)

	if duck_requests > 0:
		return

	var target_volume := (
		menu_music_volume_db
		if menu_mode
		else normal_music_volume_db
	)

	_tween_music_volume(
		target_volume,
		restore_duration
	)


func set_menu_mode(enabled: bool) -> void:
	menu_mode = enabled

	if music_bus_index == -1:
		return

	var target_volume := (
		menu_music_volume_db
		if enabled
		else normal_music_volume_db
	)

	var target_cutoff := (
		menu_cutoff_hz
		if enabled
		else gameplay_cutoff_hz
	)

	_tween_music_volume(
		target_volume,
		menu_transition_duration
	)

	_tween_low_pass(
		target_cutoff,
		menu_transition_duration,
		not enabled
	)


func _tween_music_volume(target_db: float, duration: float) -> void:
	if music_bus_index == -1:
		return

	if volume_tween:
		volume_tween.kill()

	var current_db := AudioServer.get_bus_volume_db(music_bus_index)

	volume_tween = create_tween()
	volume_tween.tween_method(
		_set_music_volume,
		current_db,
		target_db,
		duration
	)


func _set_music_volume(volume_db: float) -> void:
	AudioServer.set_bus_volume_db(
		music_bus_index,
		volume_db
	)


func _tween_low_pass(
	target_cutoff: float,
	duration: float,
	disable_after: bool
) -> void:
	var effect := AudioServer.get_bus_effect(
		music_bus_index,
		MUSIC_LOW_PASS_INDEX
	) as AudioEffectLowPassFilter

	if effect == null:
		push_warning(
			"Low-pass filter not found on Music bus at index %d"
			% MUSIC_LOW_PASS_INDEX
		)
		return

	if filter_tween:
		filter_tween.kill()

	AudioServer.set_bus_effect_enabled(
		music_bus_index,
		MUSIC_LOW_PASS_INDEX,
		true
	)

	filter_tween = create_tween()
	filter_tween.tween_property(
		effect,
		"cutoff_hz",
		target_cutoff,
		duration
	)

	if disable_after:
		await filter_tween.finished

		if not menu_mode:
			AudioServer.set_bus_effect_enabled(
				music_bus_index,
				MUSIC_LOW_PASS_INDEX,
				false
			)
