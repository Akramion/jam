class_name PuzzleLamp
extends Node2D

enum State {
	OFF,
	BLINKING,
	ON
}

@export var blink_interval := 0.25

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light: PointLight2D = $PointLight2D
@onready var blink_timer: Timer = $BlinkTimer

var current_state := State.OFF
var blink_is_on := false


func _ready() -> void:
	blink_timer.wait_time = blink_interval
	blink_timer.one_shot = false
	blink_timer.timeout.connect(_on_blink_timer_timeout)

	_apply_lamp_visual(false)


func set_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	blink_timer.stop()

	match current_state:
		State.OFF:
			blink_is_on = false
			_apply_lamp_visual(false)

		State.BLINKING:
			blink_is_on = true
			_apply_lamp_visual(true)
			blink_timer.start()

		State.ON:
			blink_is_on = true
			_apply_lamp_visual(true)


func _on_blink_timer_timeout() -> void:
	if current_state != State.BLINKING:
		return

	blink_is_on = not blink_is_on
	_apply_lamp_visual(blink_is_on)


func _apply_lamp_visual(is_on: bool) -> void:
	animated_sprite.play("on" if is_on else "off")
	point_light.enabled = is_on
