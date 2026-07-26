extends Control

@export var first_level: PackedScene

@onready var main_menu: Control = $Menu
@onready var settings: Control = $Settings

@onready var play_button: Button = $Menu/Buttons/PlayButton
@onready var settings_button: Button = $Menu/Buttons/SettingsButton
@onready var quit_button: Button = $Menu/Buttons/QuitButton

@onready var master_slider: HSlider = $Settings/CenterContainer/VBoxContainer/MasterRow/MasterSlider

@onready var music_slider: HSlider = $Settings/CenterContainer/VBoxContainer/MusicRow/MusicSlider

@onready var sfx_slider: HSlider = $Settings/CenterContainer/VBoxContainer/SfxRow/SFXSlider

@onready var fullscreen_checkbox: CheckBox = $Settings/CenterContainer/VBoxContainer/FullscreenCheckbox

@onready var back_button: Button = $Settings/CenterContainer/VBoxContainer/BackButton


func _ready() -> void:
	main_menu.show()
	settings.hide()

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)

	for button in [
		play_button,
		settings_button,
		quit_button,
		back_button
	]:
		button.mouse_entered.connect(button.grab_focus)

	# Ставим стартовые значения без сохранения.
	master_slider.value = 1.0
	music_slider.value = 1.0
	sfx_slider.value = 1.0

	fullscreen_checkbox.button_pressed = (
		DisplayServer.window_get_mode()
		== DisplayServer.WINDOW_MODE_FULLSCREEN
	)

	play_button.grab_focus()


func _on_play_pressed() -> void:
	if first_level:
		get_tree().change_scene_to_packed(first_level)
	else:
		push_warning("First Level не назначен в инспекторе")


func _on_settings_pressed() -> void:
	main_menu.hide()
	settings.show()
	master_slider.grab_focus()


func _on_back_pressed() -> void:
	settings.hide()
	main_menu.show()
	settings_button.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_master_volume_changed(value: float) -> void:
	set_bus_volume("Master", value)


func _on_music_volume_changed(value: float) -> void:
	set_bus_volume("Music", value)


func _on_sfx_volume_changed(value: float) -> void:
	set_bus_volume("SFX", value)


func set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		push_warning("Не найдена аудиошина: " + bus_name)
		return

	var should_mute := value <= 0.001

	AudioServer.set_bus_mute(bus_index, should_mute)

	if not should_mute:
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(value)
		)


func _on_fullscreen_toggled(enabled: bool) -> void:
	if enabled:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)
	else:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)
