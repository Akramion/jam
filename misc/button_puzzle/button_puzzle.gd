class_name ButtonPuzzle
extends Node

signal completed

@export var buttons: Array[WallButton]
@export var lamps: Array[PuzzleLamp]
@export var door: Door

@export var stay_completed := true

var is_completed := false


func _ready() -> void:
	if buttons.size() != lamps.size():
		push_error(
			"ButtonPuzzle: количество кнопок и ламп должно совпадать"
		)

	for button in buttons:
		button.active_changed.connect(_on_button_active_changed)

	update_puzzle()


func _on_button_active_changed(_is_active: bool) -> void:
	update_puzzle()


func update_puzzle() -> void:
	if is_completed and stay_completed:
		return

	var all_buttons_active := true

	for button in buttons:
		if not button.is_active:
			all_buttons_active = false
			break

	if all_buttons_active:
		complete_puzzle()
	else:
		update_lamps()


func update_lamps() -> void:
	for index in buttons.size():
		var button := buttons[index]
		var lamp := lamps[index]

		if button.is_active:
			lamp.set_state(PuzzleLamp.State.BLINKING)
		else:
			lamp.set_state(PuzzleLamp.State.OFF)

	if door:
		door.set_active(false)


func complete_puzzle() -> void:
	if is_completed:
		return

	is_completed = true

	for lamp in lamps:
		lamp.set_state(PuzzleLamp.State.ON)

	if door:
		door.set_active(true)

	completed.emit()

func reset_puzzle() -> void:
	is_completed = false

	for lamp in lamps:
		lamp.set_state(PuzzleLamp.State.OFF)

	update_puzzle()
	
func reset_for_new_cycle() -> void:
	is_completed = false

	for lamp in lamps:
		lamp.set_state(PuzzleLamp.State.OFF)

	if door:
		door.set_active(false)

	call_deferred("update_puzzle")
