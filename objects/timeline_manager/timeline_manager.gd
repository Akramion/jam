extends Node

@export var cycle_duration := 10.0
@export var max_clones := 3

@export var player: CharacterBody2D
@export var clone_scene: PackedScene
@export var clones_container: Node
@export var timer_label: Label

@export var level_exit: Area2D
@export var next_level: PackedScene
@export var transition_delay := 0.5

var level_is_completed := false

var cycle_time_left: float
var spawn_position: Vector2
var clone_count := 0

func _ready() -> void:
	spawn_position = player.global_position

	if level_exit:
		level_exit.level_completed.connect(_on_level_completed)

	start_cycle.call_deferred()
	
func _physics_process(delta: float) -> void:
	if level_is_completed:
		return
		
	cycle_time_left -= delta
	
	if timer_label:
		timer_label.text = "%.1f" % max(cycle_time_left, 0.0)
	
	if cycle_time_left <= 0:
		finish_cycle()

func _unhandled_input(event: InputEvent) -> void:
	if level_is_completed:
		return
		
	if event.is_action_pressed("restart_level"):
		restart_level()
		return
		
	if event.is_action_pressed("restart_recording"):
		finish_cycle()

func restart_level() -> void:
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
	var recording: Array[Dictionary] = player.stop_recording()

	if recording.is_empty():
		start_cycle()
		return

	if clone_count >= max_clones:
		print("Клоны закончились")
		return

	var clone := clone_scene.instantiate()
	clones_container.add_child(clone)

	clone.setup(recording, spawn_position)

	clone_count += 1
	start_cycle()

func _on_level_completed() -> void:
	if level_is_completed:
		return

	level_is_completed = true

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
