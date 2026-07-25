extends Node

@onready var music_emitter: FmodEventEmitter2D = $MusicEmitter
@onready var rewind_emitter: FmodEventEmitter2D = $RewindEmitter
@onready var restart_emitter: FmodEventEmitter2D = $RestartEmitter
@onready var level_complete_emitter: FmodEventEmitter2D = $LevelCompleteEmitter


func _ready() -> void:
	play_music()

func play_music() -> void:
	music_emitter.play()

func play_rewind() -> void:
	rewind_emitter.play()

func play_restart() -> void:
	restart_emitter.play()

func level_complete() -> void:
	level_complete_emitter.play()
