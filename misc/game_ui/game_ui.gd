class_name GameUI
extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var clones_label: Label = %ClonesLabel
@onready var hint_label: Label = %HintLabel
@onready var restart_label: Label = %RestartLabel


func set_time(time_left: float) -> void:
	var safe_time: float = max(time_left, 0.0)

	var seconds := int(safe_time)
	var tenths := int((safe_time - seconds) * 10.0)

	timer_label.text = "00:%02d:%d0" % [
		seconds,
		tenths
	]


func set_clones(current: int, maximum: int) -> void:
	var remaining: int = max(maximum - current, 0)
	clones_label.text = "TAPE: %02d" % remaining


func set_hint(text: String) -> void:
	hint_label.text = text
	hint_label.visible = not text.is_empty()


func set_restart_hint(text: String) -> void:
	restart_label.text = text
	restart_label.visible = not text.is_empty()
