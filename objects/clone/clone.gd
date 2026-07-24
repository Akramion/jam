extends CharacterBody2D

@export var speed: float = 250.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var recorded_inputs: Array[Vector2] = []
var frame_index := 0
var spawn_position: Vector2

func setup(inputs: Array[Vector2], start_position: Vector2) -> void:
	recorded_inputs = inputs.duplicate()
	spawn_position = start_position

	restart_playback()


func _physics_process(_delta: float) -> void:
	if frame_index >= recorded_inputs.size():
		velocity = Vector2.ZERO
		return

	var input_direction := recorded_inputs[frame_index]

	velocity = input_direction * speed

	if input_direction.x != 0:
		animated_sprite_2d.flip_h = input_direction.x < 0

	move_and_slide()

	frame_index += 1


func restart_playback() -> void:
	frame_index = 0
	global_position = spawn_position
	velocity = Vector2.ZERO
