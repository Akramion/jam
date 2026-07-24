extends CharacterBody2D

@export var speed := 250.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var recorded_inputs: Array[Vector2] = []
var is_recording := false
var last_direction := Vector2.DOWN


func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = input_direction * speed


	if input_direction != Vector2.ZERO:
		last_direction = input_direction
		play_walk_animation(input_direction)
	else:
		play_idle_animation(last_direction)

	move_and_slide()

	if is_recording:
		recorded_inputs.append(input_direction)


func start_recording() -> void:
	recorded_inputs.clear()
	is_recording = true


func stop_recording() -> Array[Vector2]:
	is_recording = false

	var result := recorded_inputs.duplicate()
	recorded_inputs.clear()

	return result
	
func play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			sprite.play("walk_left")
		else:
			sprite.play("walk_right")
	else:
		if direction.y < 0:
			sprite.play("walk_back")
		else:
			sprite.play("walk_front")


func play_idle_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			sprite.play("idle_left")
		else:
			sprite.play("idle_right")
	else:
		if direction.y < 0:
			sprite.play("idle_back")
		else:
			sprite.play("idle_front")
