extends Node2D

var recorded_positions: Array[Vector2] = []
var frame_index := 0

func setup(positions: Array[Vector2]) -> void:
	recorded_positions = positions.duplicate()
	global_position = recorded_positions[0]

func _physics_process(delta: float) -> void:
	if frame_index >= recorded_positions.size():
		return
	
	global_position = recorded_positions[frame_index]
	frame_index += 1
