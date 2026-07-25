extends Area2D

signal level_completed

var is_completed := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if is_completed:
		return

	if not body.is_in_group("player"):
		return

	is_completed = true
	set_deferred("monitoring", false)
	level_completed.emit()
