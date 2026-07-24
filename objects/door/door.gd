class_name Door
extends StaticBody2D

@export var starts_open := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_open := false


func _ready() -> void:
	_apply_state(starts_open)


func set_active(active: bool) -> void:
	if is_open == active:
		return

	_apply_state(active)


func _apply_state(opened: bool) -> void:
	is_open = opened

	# Пока нет отдельного спрайта открытой двери:
	sprite.visible = not is_open

	# Открытая дверь больше не блокирует проход.
	collision.set_deferred("disabled", is_open)
