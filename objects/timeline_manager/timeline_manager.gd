extends Node

@export var cycle_duration := 10.0
@export var max_clones := 3

@export var player: CharacterBody2D
@export var clone_scene: PackedScene
@export var clones_container: Node
@export var game_ui: GameUI

@export var level_exit: Area2D
@export var next_level: PackedScene
@export var transition_delay := 0.5

var level_is_restarting := false
var level_is_completed := false
var is_waiting_for_start := true

var cycle_time_left: float
var spawn_position: Vector2
var clone_count := 0

func _ready() -> void:
	spawn_position = player.global_position

	if level_exit:
		level_exit.level_completed.connect(_on_level_completed)

	if game_ui:
		if not game_ui.is_node_ready():
			await game_ui.ready

			game_ui.set_time(cycle_duration)
			game_ui.set_clones(clone_count, max_clones)
			game_ui.show_start_hint()
			game_ui.set_hint("[E] INTERACT")
			game_ui.set_restart_hint("[SPACE] REWIND    [R] RESTART")
	begin_level_preview()
	
func _physics_process(delta: float) -> void:
	if level_is_completed or level_is_restarting or is_waiting_for_start:
		return

	cycle_time_left -= delta

	if game_ui:
		game_ui.set_time(cycle_time_left)

	if cycle_time_left <= 0:
		finish_cycle()

func _unhandled_input(event: InputEvent) -> void:
	if level_is_completed or level_is_restarting:
		return

	if is_waiting_for_start:
		if is_start_input(event):
			get_viewport().set_input_as_handled()
			begin_level_play()

		return

	if event.is_action_pressed("restart_level"):
		restart_level()
		return

	if event.is_action_pressed("restart_recording"):
		finish_cycle()

func restart_level() -> void:
	if level_is_restarting:
		return

	level_is_restarting = true

	player.stop_recording()
	player.set_controls_enabled(false)
	player.velocity = Vector2.ZERO

	AudioManager.play_restart()

	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func start_cycle() -> void:
	reset_cycle_objects()
	cycle_time_left = cycle_duration
	player.global_position = spawn_position
	player.velocity = Vector2.ZERO
	player.start_recording()
	
	for clone in get_tree().get_nodes_in_group("clones"):
		clone.restart_playback()

func finish_cycle() -> void:
	if level_is_completed or level_is_restarting:
		return
		
	var recording: Array[Dictionary] = player.stop_recording()
	
	if clone_count >= max_clones:
		restart_level()
		return

	AudioManager.play_rewind()

	if recording.is_empty():
		start_cycle()
		return

	var clone := clone_scene.instantiate()
	clones_container.add_child(clone)

	clone.setup(recording, spawn_position)

	clone_count += 1
	
	if game_ui:
		game_ui.set_clones(clone_count, max_clones)
		
	start_cycle()

func _on_level_completed() -> void:
	if level_is_completed:
		return

	level_is_completed = true
	
	AudioManager.play_level_complete()

	player.stop_recording()
	player.velocity = Vector2.ZERO

	if player.has_method("set_controls_enabled"):
		player.set_controls_enabled(false)

	await get_tree().create_timer(transition_delay).timeout

	if next_level:
		get_tree().change_scene_to_packed(next_level)
	else:
		print("Уровень пройден")

func reset_cycle_objects() -> void:
	for object in get_tree().get_nodes_in_group("cycle_resettable"):
		if object.has_method("reset_for_new_cycle"):
			object.reset_for_new_cycle()

func begin_level_preview() -> void:
	is_waiting_for_start = true
	cycle_time_left = cycle_duration

	player.velocity = Vector2.ZERO
	player.set_controls_enabled(false)

	if game_ui:
		game_ui.set_time(cycle_duration)
		game_ui.show_start_hint()

func begin_level_play() -> void:
	if not is_waiting_for_start:
		return

	is_waiting_for_start = false
	player.set_controls_enabled(true)

	if game_ui:
		game_ui.hide_start_hint()

	start_cycle()

func is_start_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo

	if event is InputEventMouseButton:
		return event.pressed

	if event is InputEventJoypadButton:
		return event.pressed

	return false
