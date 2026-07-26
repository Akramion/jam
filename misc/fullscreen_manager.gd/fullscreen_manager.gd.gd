extends Node


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	if event.keycode != KEY_ESCAPE:
		return

	exit_fullscreen()
	get_viewport().set_input_as_handled()


func exit_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()

	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
	or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)
