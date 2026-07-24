extends CharacterBody2D

@export var clone_scene: PackedScene
@export var speed: float = 250.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var recorded_positions: Array[Vector2] = []
var is_recording := true


func _physics_process(_delta: float) -> void:
	handle_movement()
	
	if is_recording:
		recorded_positions.append(global_position)
		
	if Input.is_action_just_pressed("restart_recording"):
		print("Записано кадров: ", recorded_positions.size())
		create_clone()


func handle_movement() -> void:
	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = input_direction * speed

	if input_direction.x != 0:
		animated_sprite_2d.flip_h = input_direction.x < 0

	move_and_slide()

func create_clone() -> void:
	if recorded_positions.is_empty():
		return
	
	var clone = clone_scene.instantiate()
	get_parent().add_child(clone)
	clone.setup(recorded_positions)
	
	recorded_positions.clear()
