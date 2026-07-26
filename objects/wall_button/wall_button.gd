class_name WallButton
extends Area2D

@export var reset_on_cycle_restart := true

signal active_changed(is_active: bool)
signal pressed(button: WallButton)

enum ActivationMode {
	PERMANENT,
	TIMED
}

enum VisualState {
	OFF,
	PENDING,
	COMPLETED
}

@export var activation_mode := ActivationMode.PERMANENT
@export var active_duration := 4.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var active_timer: Timer = $ActiveTimer
@onready var press_sound: AudioStreamPlayer2D = $PressSound
@onready var release_sound: AudioStreamPlayer2D = $ReleaseSound

var is_active := false
var is_completed := false


func _ready() -> void:
	active_timer.one_shot = true
	active_timer.timeout.connect(_on_active_timer_timeout)

	set_visual_state(VisualState.OFF)


func interact(_actor: Node) -> void:
	if is_completed:
		return

	if activation_mode == ActivationMode.PERMANENT:
		activate_permanently()
	else:
		activate_temporarily()


func activate_permanently() -> void:
	if is_active:
		return

	is_active = true
	is_completed = true

	active_timer.stop()
	set_visual_state(VisualState.COMPLETED)

	press_sound.play()
	active_changed.emit(true)
	pressed.emit(self)


func activate_temporarily() -> void:
	if is_active:
		return

	press_sound.play()
	is_active = true
	set_visual_state(VisualState.PENDING)

	active_timer.start(active_duration)

	active_changed.emit(true)
	pressed.emit(self)


func complete() -> void:
	if is_completed:
		return

	is_active = true
	is_completed = true

	active_timer.stop()
	set_visual_state(VisualState.COMPLETED)

	active_changed.emit(true)


func reset_button() -> void:
	active_timer.stop()

	var was_active := is_active

	is_active = false
	is_completed = false

	set_visual_state(VisualState.OFF)

	if was_active:
		release_sound.play()
		active_changed.emit(false)


func _on_active_timer_timeout() -> void:
	if is_completed:
		return

	is_active = false
	set_visual_state(VisualState.OFF)

	release_sound.play()
	active_changed.emit(false)


func set_visual_state(state: VisualState) -> void:
	match state:
		VisualState.OFF:
			animated_sprite.play("off")

		VisualState.PENDING:
			animated_sprite.play("on")

		VisualState.COMPLETED:
			animated_sprite.play("on")

func reset_for_new_cycle() -> void:
	if not reset_on_cycle_restart:
		return

	active_timer.stop()

	var was_active := is_active

	is_active = false
	is_completed = false

	set_visual_state(VisualState.OFF)

	if was_active:
		active_changed.emit(false)
