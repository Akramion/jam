extends CharacterBody2D

@export var speed := 190.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@export var step_interval := 0.32

var step_time_left := 0.0

var recorded_inputs: Array[Dictionary] = []
var is_recording := false
var interact_requested := false

var last_direction := Vector2.DOWN
var controls_enabled := true


func _physics_process(delta: float) -> void:
	if not controls_enabled:
		velocity = Vector2.ZERO
		interact_requested = false
		move_and_slide()
		return

	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = input_direction * speed
	
	_update_footsteps(input_direction, delta)

	if input_direction != Vector2.ZERO:
		last_direction = input_direction
		play_walk_animation(input_direction)
	else:
		play_idle_animation(last_direction)

	move_and_slide()

	# Взаимодействуем после движения, чтобы InteractionArea
	# уже находилась в актуальной позиции.
	if interact_requested:
		try_interact()

	if is_recording:
		var frame_data := {
			"direction": input_direction,
			"interact": interact_requested
		}

		recorded_inputs.append(frame_data)

	# Нажатие должно проиграться только на одном физическом кадре.
	interact_requested = false


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled:
		return

	if event.is_action_pressed("interact"):
		interact_requested = true


func start_recording() -> void:
	recorded_inputs.clear()
	interact_requested = false
	is_recording = true


func stop_recording() -> Array[Dictionary]:
	is_recording = false
	interact_requested = false

	var result: Array[Dictionary] = recorded_inputs.duplicate(true)
	recorded_inputs.clear()

	return result


func try_interact() -> void:
	var available_areas := interaction_area.get_overlapping_areas()

	for area in available_areas:
		if area.has_method("interact"):
			area.interact(self)
			return


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


func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled

	if not controls_enabled:
		velocity = Vector2.ZERO
		interact_requested = false

func _update_footsteps(direction: Vector2, delta: float) -> void:
	if direction == Vector2.ZERO:
		step_time_left = 0.0
		return

	step_time_left -= delta

	if step_time_left <= 0.0:
		#steps_sound.play()
		step_time_left = step_interval
