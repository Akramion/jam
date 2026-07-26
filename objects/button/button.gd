class_name PressureButton
extends Area2D

signal activation_changed(active: bool)

@export var targets: Array[Node]
@export var press_sounds: Array[AudioStream]

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var press_sound: AudioStreamPlayer2D = $PressSound
@onready var release_sound: AudioStreamPlayer2D = $ReleaseSound

var bodies_on_button: Array[Node2D] = []
var is_active := false
var current_note_index := 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_update_visual()


func _on_body_entered(body: Node2D) -> void:
	if not _can_press(body):
		return

	if body not in bodies_on_button:
		bodies_on_button.append(body)

	_update_state()


func _on_body_exited(body: Node2D) -> void:
	if body not in bodies_on_button:
		return

	bodies_on_button.erase(body)
	_update_state()


func _can_press(body: Node2D) -> bool:
	return (
		body.is_in_group("player")
		or body.is_in_group("clones")
	)


func _update_state() -> void:
	var new_state := not bodies_on_button.is_empty()

	if new_state == is_active:
		return

	is_active = new_state

	_update_visual()
	_play_state_sound()
	_notify_targets()

	activation_changed.emit(is_active)


func _update_visual() -> void:
	# Frame 0 — отпущена, Frame 1 — нажата.
	if is_active:
		animated_sprite_2d.play("on")
	else:
		animated_sprite_2d.play("off")


func _notify_targets() -> void:
	for target in targets:
		if not is_instance_valid(target):
			continue

		if target.has_method("set_active"):
			target.set_active(is_active)
		else:
			push_warning(
				"Target %s does not have set_active(active)" % target.name
			)

func _play_state_sound() -> void:
	if is_active:
		play_next_note()
	else:
		release_sound.play()
	
func play_next_note() -> void:
	if press_sounds.is_empty():
		return

	press_sound.stream = press_sounds[current_note_index]
	press_sound.play()

	current_note_index += 1

	if current_note_index >= press_sounds.size():
		current_note_index = 0
