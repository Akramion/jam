extends CharacterBody2D

@export var speed: float = 190.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var recorded_inputs: Array[Dictionary] = []
var frame_index := 0
var spawn_position: Vector2
var last_direction := Vector2.DOWN


func setup(
	inputs: Array[Dictionary],
	start_position: Vector2
) -> void:
	recorded_inputs = inputs.duplicate(true)
	spawn_position = start_position

	restart_playback()


func _physics_process(_delta: float) -> void:
	if frame_index >= recorded_inputs.size():
		velocity = Vector2.ZERO
		play_idle_animation(last_direction)
		return

	var frame_data: Dictionary = recorded_inputs[frame_index]

	var input_direction: Vector2 = frame_data.get(
		"direction",
		Vector2.ZERO
	)

	var should_interact: bool = frame_data.get(
		"interact",
		false
	)

	velocity = input_direction * speed

	if input_direction != Vector2.ZERO:
		last_direction = input_direction
		play_walk_animation(input_direction)
	else:
		play_idle_animation(last_direction)

	move_and_slide()

	# Повторяем взаимодействие на том же кадре,
	# на котором его выполнил игрок.
	if should_interact:
		try_interact()

	frame_index += 1


func try_interact() -> void:
	var available_areas := interaction_area.get_overlapping_areas()

	for area in available_areas:
		if area.has_method("interact"):
			area.interact(self)
			return


func restart_playback() -> void:
	frame_index = 0
	global_position = spawn_position
	velocity = Vector2.ZERO
	last_direction = Vector2.DOWN


func play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			animated_sprite_2d.play("walk_left")
		else:
			animated_sprite_2d.play("walk_right")
	else:
		if direction.y < 0:
			animated_sprite_2d.play("walk_back")
		else:
			animated_sprite_2d.play("walk_front")


func play_idle_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			animated_sprite_2d.play("idle_left")
		else:
			animated_sprite_2d.play("idle_right")
	else:
		if direction.y < 0:
			animated_sprite_2d.play("idle_back")
		else:
			animated_sprite_2d.play("idle_front")
