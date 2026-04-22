extends PathFollow3D

@export var rail_speed: float = 0.28

func _process(delta: float) -> void:
	progress_ratio += rail_speed * delta
