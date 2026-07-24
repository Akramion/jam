extends Node

@export var cycle_duration := 10.0
@export var max_clones := 3

@export var player: CharacterBody2D
@export var clone_scene: PackedScene
@export var clones_container: Node
@export var timer_label: Label

var cycle_time_left: float
var spawn_position: Vector2
var clone_count := 0

func _ready() -> void:
	spawn_position = player.global_position
	start_cycle()
	
func _physics_process(delta: float) -> void:
	cycle_time_left -= delta
	
	if timer_label:
		timer_label.text = "%.1f" % max(cycle_time_left, 0.0)
	
	if cycle_time_left <= 0:
		finish_cycle()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_recording"):
		finish_cycle()

func start_cycle() -> void:
	cycle_time_left = cycle_duration
	player.global_position = spawn_position
	player.velocity = Vector2.ZERO
	player.start_recording()
	
	for clone in get_tree().get_nodes_in_group("clones"):
		clone.restart_playback()

func finish_cycle() -> void:
	var recording: Array[Vector2] = player.stop_recording()
	
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
