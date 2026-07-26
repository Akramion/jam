extends Control

@onready var title_label: Label = %TitleLabel
@onready var thanks_label: Label = %ThanksLabel
@onready var press_label: Label = %PressLabel

@export var menu_scene: PackedScene

var can_continue := false

func _unhandled_input(event: InputEvent) -> void:
	if not can_continue:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		go_to_menu()
		return

	if event is InputEventMouseButton and event.pressed:
		go_to_menu()


func _ready() -> void:
	title_label.modulate.a = 0.0
	thanks_label.modulate.a = 0.0
	press_label.modulate.a = 0.0

	await get_tree().create_timer(0.8).timeout

	await _fade_in(title_label, 0.8)
	await get_tree().create_timer(0.4).timeout

	await _fade_in(thanks_label, 0.7)
	await get_tree().create_timer(1.0).timeout

	await _fade_in(press_label, 0.6)
	_start_press_blink()


func _fade_in(label: CanvasItem, duration: float) -> void:
	var tween := create_tween()

	tween.tween_property(
		label,
		"modulate:a",
		1.0,
		duration
	)

	await tween.finished


func _start_press_blink() -> void:
	var tween := create_tween()
	tween.set_loops()

	tween.tween_property(
		press_label,
		"modulate:a",
		0.35,
		0.8
	)

	tween.tween_property(
		press_label,
		"modulate:a",
		1.0,
		0.8
	)
	
	can_continue = true

func go_to_menu() -> void:
	if menu_scene == null:
		push_warning("Menu scene is not assigned")
		return

	get_tree().change_scene_to_packed(menu_scene)
